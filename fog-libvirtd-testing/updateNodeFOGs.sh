#!/bin/bash
cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$cwd/settings.sh"
branch=$1


#Create hidden file for each node - for status reporting.
for i in "${storageNodes[@]}"
do
    echo "-1" > $cwd/.$i
done


#Loop through each box.
for i in "${storageNodes[@]}"
do
    echo "$(date +%x_%r) Installing branch \"$branch\" onto $i" >> $output

    #Kick the tires. It helps, makes ssh load into ram, makes the switch learn where the traffic needs to go.
    nonsense=$(timeout $sshTime ssh -o ConnectTimeout=$sshTimeout $i "echo wakeup")
    nonsense=$(timeout $sshTime ssh -o ConnectTimeout=$sshTimeout $i "echo get ready")

    #Start the installation process.
    timeout $sshTime scp -o ConnectTimeout=$sshTimeout $cwd/installBranch.sh $i:/root/installBranch.sh
    printf $(timeout $fogTimeout ssh -o ConnectTimeout=$sshTimeout $i "/root/./installBranch.sh $branch;echo \$?") > $cwd/.$i
    timeout $sshTime ssh -o ConnectTimeout=$sshTimeout $i "rm -f /root/installBranch.sh"
    status=$(cat $cwd/.$i)

    echo "$(date +%x_%r) Return code was $status" >> $output

    #make sure streaks dir exists.
    mkdir -p $streakDir

    if [[ "$status" == "0" ]]; then


        if [[ -f ${streakDir}/${i}_fog_${branch}_current_streak ]]; then
            current_streak=$(head -n 1 ${streakDir}/${i}_fog_${branch}_current_streak)
        else
            current_streak="0"
        fi
        if [[ -f ${streakDir}/${i}_fog_${branch}_record_streak ]]; then
            record_streak=$(head -n 1 ${streakDir}/${i}_fog_${branch}_record_streak)
        else
            record_streak="0"
        fi
        current_streak=$(($current_streak + 1))
        if [[ $current_streak -gt $record_streak ]]; then
            record_streak=$current_streak
        fi
        echo $current_streak > ${streakDir}/${i}_fog_${branch}_current_streak
        echo $record_streak > ${streakDir}/${i}_fog_${branch}_record_streak


        echo "$i success with \"$branch\"" >> $report
        echo "$(date +%x_%r) $i success with \"$branch\"" >> $output
        echo '<tr>' >> $installer_dashboard
        echo "<td>${i}</td>" >> $installer_dashboard
        echo "<td>${branch}</td>" >> $installer_dashboard
        echo "<td>${green}</td>" >> $installer_dashboard
	echo "<td></td>" >> $installer_dashboard
	echo "<td></td>" >> $installer_dashboard
	echo "<td>${current_streak}</td>" >> $installer_dashboard
	echo "<td>${record_streak}</td>" >> $installer_dashboard
        echo '</tr>' >> $installer_dashboard
    else

        if [[ -f ${streakDir}/${i}_fog_${branch}_current_streak ]]; then
            current_streak=$(head -n 1 ${streakDir}/${i}_fog_${branch}_current_streak)
        else
            current_streak="0"
        fi
        if [[ -f ${streakDir}/${i}_fog_${branch}_record_streak ]]; then
            record_streak=$(head -n 1 ${streakDir}/${i}_fog_${branch}_record_streak)
        else
            record_streak="0"
        fi
        #Tire kick.
        timeout $sshTime ssh -o ConnectTimeout=$sshTimeout $i "echo \"wakeup\"" > /dev/null 2>&1
        timeout $sshTime ssh -o ConnectTimeout=$sshTimeout $i "echo \"get ready\"" > /dev/null 2>&1


        foglog=$(timeout $sshTime ssh -o ConnectTimeout=$sshTimeout $i "ls -dtr1 /root/git/fogproject/bin/error_logs/* | tail -1")
        rightNow=$(date +%Y-%m-%d_%H-%M)
        mkdir -p "$webdir/$i/fog"
        chown $permissions $webdir/$i/fog
        if [[ -f /root/$(basename $foglog) ]]; then
            rm -f /root/$(basename $foglog)
        fi
        if [[ -f /root/apache.log ]]; then
            rm -f /root/apache.log
        fi

        #Get fog log.
        timeout $sshTime scp -o ConnectTimeout=$sshTimeout $i:$foglog /root/$(basename $foglog) > /dev/null 2>&1
        #Get apache log. It can only be in one of two spots.
        timeout $sshTime scp -o ConnectTimeout=$sshTimeout $i:/var/log/httpd/error_log $webdir/$i/fog/${rightNow}_apache.log > /dev/null 2>&1
        timeout $sshTime scp -o ConnectTimeout=$sshTimeout $i:/var/log/apache2/error.log $webdir/$i/fog/${rightNow}_apache.log > /dev/null 2>&1
        #Set owernship.
        chown $permissions $webdir/$i/fog/${rightNow}_apache.log > /dev/null 2>&1

        foglog=$(basename $foglog)
        commit=$(timeout $sshTime ssh -o ConnectTimeout=$sshTimeout $i "cd /root/git/fogproject;git rev-parse HEAD")
        echo "Date=$rightNow" > $webdir/$i/fog/${rightNow}_fog.log
        echo "Branch=$branch" >> $webdir/$i/fog/${rightNow}_fog.log
        echo "Commit=$commit" >> $webdir/$i/fog/${rightNow}_fog.log
        echo "OS=$i" >> $webdir/$i/fog/${rightNow}_fog.log
        echo "Log_Name=$foglog" >> $webdir/$i/fog/${rightNow}_fog.log
        echo "#####Begin Log#####" >> $webdir/$i/fog/${rightNow}_fog.log
        echo "" >> $webdir/$i/fog/${rightNow}_fog.log
        cat /root/$foglog >> $webdir/$i/fog/${rightNow}_fog.log
        rm -f /root/$foglog
        chown $permissions $webdir/$i/fog/${rightNow}_fog.log



        if [[ -z $status ]]; then
            echo "$i failure with \"$branch\", returned no exit code" >> $report
            echo "$(date +%x_%r) $i failure with \"$branch\", returned no exit code" >> $output
            echo '<tr>' >> $installer_dashboard
            echo "<td>${i}</td>" >> $installer_dashboard
            echo "<td>${branch}</td>" >> $installer_dashboard
            echo "<td>${orange}</td>" >> $installer_dashboard
            if [[ ! -z $foglog || ! -z $commit  ]]; then
                echo "<td><a href=\"http://${domainName}${port}${netdir}/$i/fog/${rightNow}_fog.log\">Fog</a></td>" >> $installer_dashboard
            else
                echo "<td>Could not be retrieved.</td>" >> $installer_dashboard
            fi
            if [[ -f $webdir/$i/fog/${rightNow}_apache.log ]]; then
                echo "<td><a href=\"http://${domainName}${port}${netdir}/$i/fog/${rightNow}_apache.log\">Apache</a></td>" >> $installer_dashboard
            else
                echo "<td>Could not be retrieved.</td>" >> $installer_dashboard
            fi
	    echo "<td>${current_streak}</td>" >> $installer_dashboard
	    echo "<td>${record_streak}</td>" >> $installer_dashboard
            echo '</tr>' >> $installer_dashboard
        else
            case $status in
                -1) 
                    echo "$i failure with \"$branch\", did not return within time limit \"$fogTimeout\"" >> $report
                    echo "$(date +%x_%r) $i failure with \"$branch\", did not return within time limit \"$fogTimeout\"" >> $output
                    echo '<tr>' >> $installer_dashboard
                    echo "<td>${i}</td>" >> $installer_dashboard
                    echo "<td>${branch}</td>" >> $installer_dashboard
                    echo "<td>${orange}</td>" >> $installer_dashboard
                    ;;
                1)
                    echo "$i failure with \"$branch\", no branch passed" >> $report
                    echo "$(date +%x_%r) $i failure with \"$branch\", no branch passed" >> $output
                    echo '<tr>' >> $installer_dashboard
                    echo "<td>${i}</td>" >> $installer_dashboard
                    echo "<td>${branch}</td>" >> $installer_dashboard
                    echo "<td>${orange}</td>" >> $installer_dashboard
                    ;;
                2)
                    echo "$i failure with \"$branch\", failed to reset git" >> $report
                    echo "$(date +%x_%r) $i failure with \"$branch\", failed to reset git" >> $output
                    echo '<tr>' >> $installer_dashboard
                    echo "<td>${i}</td>" >> $installer_dashboard
                    echo "<td>${branch}</td>" >> $installer_dashboard
                    echo "<td>${orange}</td>" >> $installer_dashboard
                    ;;
                3)
                    echo "$i failure with \"$branch\", failed to 'git pull'" >> $report
                    echo "$(date +%x_%r) $i failure with \"$branch\", failed to 'git pull'" >> $output
                    echo '<tr>' >> $installer_dashboard
                    echo "<td>${i}</td>" >> $installer_dashboard
                    echo "<td>${branch}</td>" >> $installer_dashboard
                    echo "<td>${orange}</td>" >> $installer_dashboard
                    ;;
                4)
                    echo "$i failure with \"$branch\", failed to checkout git" >> $report
                    echo "$(date +%x_%r) $i failure with \"$branch\", failed to checkout git" >> $output
                    echo '<tr>' >> $installer_dashboard
                    echo "<td>${i}</td>" >> $installer_dashboard
                    echo "<td>${branch}</td>" >> $installer_dashboard
                    echo "<td>${orange}</td>" >> $installer_dashboard
                    ;;
                5) 
                    echo "$i failure with \"$branch\", failed to change directory" >> $report
                    echo "$(date +%x_%r) $i failure with \"$branch\", failed to change directory" >> $output
                    echo '<tr>' >> $installer_dashboard
                    echo "<td>${i}</td>" >> $installer_dashboard
                    echo "<td>${branch}</td>" >> $installer_dashboard
                    echo "<td>${orange}</td>" >> $installer_dashboard
                    ;;
                6)
                    echo "$i failure with \"$branch\", failed installation" >> $report
                    echo "$(date +%x_%r) $i failure with \"$branch\", failed installation" >> $output
                    echo '<tr>' >> $installer_dashboard
                    echo "<td>${i}</td>" >> $installer_dashboard
                    echo "<td>${branch}</td>" >> $installer_dashboard
                    echo "<td>${red}</td>" >> $installer_dashboard
                    ;;
                *)
                    echo "$i failure with \"$branch\", failed with exit code \"$status\"" >> $report
                    echo "$(date +%x_%r) $i failure with \"$branch\", failed with exit code \"$status\"" >> $output
                    echo '<tr>' >> $installer_dashboard
                    echo "<td>${i}</td>" >> $installer_dashboard
                    echo "<td>${branch}</td>" >> $installer_dashboard
                    echo "<td>${orange}</td>" >> $installer_dashboard
                    ;;
            esac
            if [[ ! -z $foglog || ! -z $commit  ]]; then
                echo "<td><a href=\"http://${domainName}${port}${netdir}/$i/fog/${rightNow}_fog.log\">Fog</a></td>" >> $installer_dashboard
            else
                echo "<td>Could not be retrieved</td>" >> $installer_dashboard
            fi
            if [[ -f $webdir/$i/fog/${rightNow}_apache.log ]]; then
                echo "<td><a href=\"http://${domainName}${port}${netdir}/$i/fog/${rightNow}_apache.log\">Apache</a></td>" >> $installer_dashboard
            else
                echo "<td>Could not be retrieved</td>" >> $installer_dashboard
            fi
            current_streak="0"
            if [[ $current_streak -gt $record_streak ]]; then
                record_streak=$current_streak
            fi
            echo $current_streak > ${streakDir}/${i}_fog_${branch}_current_streak
            echo $record_streak > ${streakDir}/${i}_fog_${branch}_record_streak
	    echo "<td>${current_streak}</td>" >> $installer_dashboard
	    echo "<td>${record_streak}</td>" >> $installer_dashboard
	    echo '</tr>' >> $installer_dashboard
        fi


        if [[ ! -z $foglog || ! -z $commit  ]]; then
            echo "Fog log: http://${domainName}${port}${netdir}/$i/fog/${rightNow}_fog.log" >> $report
            echo "$(date +%x_%r) Fog log: http://${domainName}${port}${netdir}/$i/fog/${rightNow}_fog.log" >> $output
        else
            rm -f $webdir/$i/fog/${rightNow}_fog.log > /dev/null 2>&1
            echo "No fog log could be retrieved from $i" >> $report
            echo "$(date +%x_%r) No fog log could be retrieved from $i" >> $output
        fi
 
        if [[ -f $webdir/$i/fog/${rightNow}_apache.log ]]; then
            echo "Apache log: http://${domainName}${port}${netdir}/$i/fog/${rightNow}_apache.log" >> $report
            echo "$(date +%x_%r) Apache log: http://${domainName}${port}${netdir}/$i/fog/${rightNow}_apache.log" >> $output
        else
            echo "No apache log could be retrieved from $i" >> $report
            echo "$(date +%x_%r) No apache log could be retrieved from $i" >> $output
        fi

    fi
done




#Cleanup after all is done.
for i in "${storageNodes[@]}"
do
    rm -f $cwd/.$i
done


