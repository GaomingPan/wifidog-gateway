#!/bin/sh                                                                                                       
run=`pidof wifidog`                                                                                             
gateway_id=$(uci get wifidog.@wifidog[0].gateway_id)                                                            
gateway_interface=$(uci get wifidog.@wifidog[0].gateway_interface)                                              
gateway_eninterface=$(uci get wifidog.@wifidog[0].gateway_eninterface)                                          
gateway_hostname=$(uci get wifidog.@wifidog[0].gateway_hostname)                                                
gateway_httpport=$(uci get wifidog.@wifidog[0].gateway_httpport)                                                
gateway_path=$(uci get wifidog.@wifidog[0].gateway_path)                                                        
gateway_connmax=$(uci get wifidog.@wifidog[0].gateway_connmax)                                                  
ssl_enable=$(uci get wifidog.@wifidog[0].ssl_enable)                                                            
check_interval=$(uci get wifidog.@wifidog[0].check_interval)                                                    
client_timeout=$(uci get wifidog.@wifidog[0].client_timeout)                                                    
sslport=$(uci get wifidog.@wifidog[0].sslport)                                                                  
deamo_enable=$(uci get wifidog.@wifidog[0].deamo_enable)                                                        
gatewayport=$(uci get wifidog.@wifidog[0].gatewayport)                                                          
myz_mac=$(uci get wifidog.@wifidog[0].myz_mac)                                                                  
tbmd_url=$(uci get wifidog.@wifidog[0].bmd_url)                                                                 
thmd_url=$(uci get wifidog.@wifidog[0].hmd_url)                                                                 
bmd_url=`echo $tbmd_url | tr " " ","`                                                                           
hmd_url=`echo $thmd_url | tr " " ","`  
#touch files                                                                                                    
mkdir -p /tmp/.white_black_list                                                                                 
                                                                                                                
#compare                                                                                                        
while [ true ]                                                                                                  
do                                                                                                              
        #detect                                                                                                 
        iptables -t nat -L WiFiDog_"$gateway_interface"_WhiteList -n --line-numbers|awk '{for(i=6;i<NF;i++)print
        iptables -t mangle -L WiFiDog_"$gateway_interface"_BlackList -n --line-numbers|awk '{for(i=6;i<NF;i++)pr
                                                                                                                
        rm /tmp/.white_black_list/.white_list_tmp                                                               
        for white_list in $tbmd_url                                                                             
        do                                                                                                      
                nslookup $white_list |sed "1d"|sed "1d" |sed "1d" |sed "1d"|awk '{for(i=3;i<NF;i++)printf $i "";
        done                                                                                                    
        invalid=`grep -e ".*0\.0\..*" /tmp/.white_black_list/.white_list_tmp -rn|cut -d : -f 1`                 
    [ $invalid ] && sed -r -i "/"$invalid/"d" /tmp/.white_black_list/.white_list_tmp                            
                                                                                                                
        rm /tmp/.white_black_list/.black_list_tmp 
        for black_list in $thmd_url                                                                             
        do                                                                                                      
                nslookup $black_list |sed "1d"|sed "1d" |sed "1d" |sed "1d"|awk '{for(i=3;i<NF;i++)printf $i "";
        done                                                                                                    
        invalid=`grep -e ".*0\.0\..*" /tmp/.white_black_list/.black_list_tmp -rn|cut -d : -f 1`                 
    [ $invalid ] && sed -r -i "/"$invalid/"d" /tmp/.white_black_list/.black_list_tmp                            
                                                                                                                
        #white                                                                                                  
        while read line_new                                                                                     
        do                                                                                                      
                i=0                                                                                             
                                                                                                                
                 while read line_old                                                                            
                do                                                                                              
                         if [ "$line_new" != "$line_old" ]; then                                                
                                i=1                                                                             
                         else                                                                                   
                                i=0                                                                             
                                break 
                         fi                                                                                     
                done < /tmp/.white_black_list/.white_list                                                       
                                                                                                                
                if [ "$i" -eq "1" ]; then                                                                       
                        iptables -t nat -A WiFiDog_"$gateway_interface"_WhiteList -d "$line_new" -j ACCEPT      
                        iptables -t filter -A WiFiDog_"$gateway_interface"_WhiteList -d "$line_new" -j ACCEPT   
                        #echo "-------------------------------------------------------------------------------li
                fi                                                                                              
        done < /tmp/.white_black_list/.white_list_tmp                                                           
                                                                                                                
        sleep 10                                                                                                
                                                                                                                
        #black                                                                                                  
        while read line_new                                                                                     
        do                                                                                                      
                i=0                                                                                             
                                                                                                                
                 while read line_old 
                do                                                                                              
                         if [ "$line_new" != "$line_old" ]; then                                                
                                i=1                                                                             
                         else                                                                                   
                                i=0                                                                             
                                break                                                                           
                         fi                                                                                     
                done < /tmp/.white_black_list/.black_list                                                       
                                                                                                                
                if [ "$i" -eq "1" ]; then                                                                       
                        iptables -t mangle -A WiFiDog_"$gateway_interface"_BlackList -d "$line_new" -j DROP     
                        #echo "-------------------------------------------------------------------------------li
                fi                                                                                              
        done < /tmp/.white_black_list/.black_list_tmp                                                           
                                                                                                                
        sleep 10                                                                                                
done


