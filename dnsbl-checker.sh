#!/bin/bash

# Load config file
source ./dnsbl.config

# Ask user for output format
echo "Choose report format: [text/json/html]"
read -r reportFormat

# Ensure log directory exists
[[ -d "$logFolder" ]] || mkdir -p "$logFolder"

# Initialize report files
jsonReport="$logFolder/report.json"
htmlReport="$logFolder/report.html"
textReport="$logFolder/report.txt"
: > "$textReport"
: > "$jsonReport"

# Start HTML structure if needed
if [[ "$reportFormat" == "html" ]]; then
cat <<EOF > "$htmlReport"
<!DOCTYPE html>
<html>
<head>
<title>DNSBL Report</title>
<style>
  body { font-family: Arial; }
  table { border-collapse: collapse; width: 100%; }
  th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
</style>
</head>
<body>
<h2>DNSBL Report</h2>
<table>
<tr><th>IP Address</th><th>Status</th><th>DNSBL</th></tr>
EOF
fi

# Begin JSON array
echo "[" >> "$jsonReport"
jsonComma=""

reverse_ip() {
    local ip=$1
    IFS='.' read -r a b c d <<< "$ip"
    echo "$d.$c.$b.$a"
}

write_report() {
    local ip=$1
    local dnsbl=$2
    local listed=$3

    # Write to text
    local msg="$ip is ${listed:+listed}${listed:-not listed} on $dnsbl"
    echo "$msg" >> "$textReport"

    # Write to JSON
    echo "${jsonComma}{\"ip\":\"$ip\",\"dnsbl\":\"$dnsbl\",\"listed\":$([[ -n "$listed" ]] && echo true || echo false)}" >> "$jsonReport"
    jsonComma=","

    # Write to HTML
    if [[ "$reportFormat" == "html" ]]; then
        echo "<tr><td>$ip</td><td>$([[ -n "$listed" ]] && echo 'Blacklisted' || echo 'Clean')</td><td>$dnsbl</td></tr>" >> "$htmlReport"
    fi
}

send_notifications() {
    local ip=$1
    local dnsbl=$2
    local message="Your server IP $ip is listed in DNSBL: $dnsbl"

    if [[ "$emailEnable" == "YES" ]]; then
        for email in "${emailTo[@]}"; do
            echo "$message" | mail -v -s "Blacklist Alert" "$email" \
                -aFrom:"$emailFrom" \
                -S smtp="$SMTPServerIP" \
                -S smtp-use-starttls \
                -S smtp-auth=login \
                -S smtp-auth-user="$mailUserName" \
                -S smtp-auth-password="$mailPassword" \
                -S ssl-verify=ignore
        done
    fi

    if [[ "$telegramEnable" == "YES" ]]; then
        for chat_id in "${chatIDs[@]}"; do
            curl -s -X POST "https://api.telegram.org/bot${telegramToken}/sendMessage" \
                -d "chat_id=$chat_id&text=$message"
        done
    fi
}

check_dnsbl() {
    local ip=$1
    local reversed
    reversed=$(reverse_ip "$ip")
    echo "Checking $ip (reversed: $reversed)..."

    for bl in "${dnsblList[@]}"; do
        local query="${reversed}.${bl}"
        local result
        result=$(dig +short "$query")

        if [[ "$result" == 127.0.0.* ]]; then
            write_report "$ip" "$bl" "yes"
            send_notifications "$ip" "$bl"
        else
            write_report "$ip" "$bl" ""
        fi
    done
}

# Main loop
for ip in "${ipAddresses[@]}"; do
    check_dnsbl "$ip"
done

# Finalize HTML
if [[ "$reportFormat" == "html" ]]; then
    echo "</table></body></html>" >> "$htmlReport"
fi

# Finalize JSON
echo "]" >> "$jsonReport"

# Show report path
case "$reportFormat" in
    json) echo "JSON report generated: $jsonReport" ;;
    html) echo "HTML report generated: $htmlReport" ;;
    *)    echo "Text report generated: $textReport" ;;
esac
