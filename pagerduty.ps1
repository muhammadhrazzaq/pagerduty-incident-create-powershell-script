$token=$args[0]
$from = $args[1]
$Path = $args[2]
$serviceID = $args[3]
# $Path = "C:\Users\HEADWAY\Desktop\inshaallah\gcp\empty"

######################################################################

# Function to check the file creation date

#######################################################################


function get_created_date($Path) {

    $file_createdate = (Get-Item $Path ).LastWriteTime
    $dateTime_now = get-date
    #echo(($dateTime_now - $file_createdate))
    $day = (($dateTime_now - $file_createdate).days)

    $size = (Get-Content $Path).length

    return $day , $size
}



###########################################################################

# function to send the alert on Pagerduty

###########################################################################

function send_incident($message) {

    $Header = @{
        "authorization" = $token
        'From'          =  $from #'30049518@student.southwales.ac.uk'
        "Accept"        = "application/vnd.pagerduty+json;version=2"
    }

    $Body = @"

    {

  "incident": {
    "type": "incident",
    "title": "$message",
    "service": {
      "id": "$serviceID",
      "type": "service_reference"
    },
    "priority": {
      "id": "P53ZZH",
      "type": "priority_reference"
    },
    "urgency": "high",
    "incident_key": "",
    "body": {
      "type": "incident_body",
      "details": "Please check token"
    },
    "escalation_policy": {
     
    }
  }

}
"@

    $Parameters = @{
        Method      = "POST"
        Uri         = "https://api.pagerduty.com/incidents"
        Headers     = $Header
        ContentType = "application/json"
        Body        = $Body 
        
    }
    Invoke-RestMethod @Parameters
}


##################################################################################

# Main Function in which all the conditons and checks have been implemented

##################################################################################


function main {

    $days , $size = (get_created_date($Path))
    #echo($size)

    if ( $days -gt 0 -Or $size -eq 0 ) {
        if ($size -eq 0){
            $message = "Token file is empty , So its invalid"
            send_incident($message)
        }
        ELSE {
            $message = "Token file is not generated , Please manually generate the file"
            send_incident($message)

        }
    }

    Else {
        $message = "Token file is Valid"
        send_incident($message)
    }


}
main