   
    $ResultFileName = "Results_" + $(get-date -f yyyy-MM-dd)
    $ResultsCSV = "S:\PII\"+ $ResultFileName + ".csv"
    $Directory = "C:\temp"

    # REgular Expressions for PII
    $RX_testing =  '\d\d\d-\d\d-\d\d\d\d'
    $RX_CreditCard = "(?:[456][0-9]{15}","[456][0-9]{3}[-| ][0-9]{4}[-| ][0-9]{4}[-| ][0-9]{4}?)"
    $RX_SSN1 = "^.*(ssn|social|security).*$"
    $RX_SSN2 =  "(?:[0-9]{3}[-| ][0-9]{2}[-| ][0-9]{4}?)"
    $RX_DOB = "^.*(DOB|dob).*$"

    $Arr_RegEx = @( "^.*(ssn|social|security).*$", "^.*(DOB|dob).*$",  "(?:[0-9]{3}[-| ][0-9]{2}[-| ][0-9]{4}?)")

    $Total_PII   = 0
    $Total_ScannedFiles = 0
    $PII_Type
    

    $TextFiles = Get-ChildItem $Directory -Include *.txt*,*.rtf*,*.eml*,*.msg*,*.dat*,*.ini*,*.mht* -Recurse

     $file2 =  new-object System.IO.StreamWriter($ResultsCSV) #output Stream
     $file2.WriteLine('Matches,File Path') # write header

    foreach ($FileSearched in $TextFiles) {   #loop over files in folder

       $Total_ScannedFiles += 1

        #    $text = [IO.File]::ReadAllText($FileSearched)
        $file = New-Object System.IO.StreamReader ($FileSearched)  # Input Stream

        while ($text = $file.ReadLine()) {      # read line by line

         foreach ($element in $Arr_RegEx){      # regular expressions to eval

            foreach ($match in ([regex]$element).Matches($text)) { 
                    $Total_PII = $Total_PII + 1  
                   # write line to output stream
                   Switch($element)
                   {$RX_SSN1{ $PII_Type ="SSN Initials?"}
                    $RX_SSN2{ $PII_Type ="SSN Numbers?"}
                    $RX_DOB{ $PII_Type ="DOB?"}
                   }
                   $file2.WriteLine("{0},{1},$PII_Type'",$match.Value, $FileSearched.fullname )  
            } #foreach $match


         } # foreach $Arr_RegEx

        }#while $file

         $file.close(); 
          
    } #foreach  
    $file2.close()

    $From = "csaab@themdc.com"
    $To =   "csaab@themdc.com"
    $Cc =   "csaab@themdc.com"
    $Subject = "PII Script Execution and Scan Results"
    $Body = " A Total of <b><font=Arial color='green'>"+  $Total_PII + "</font></b>  potential PII items and their locations were found. The scan was recursively performed on the " + $Directory + " Drive(s). A Total of <b><font=Arial color='green'>" + $Total_ScannedFiles + "</font></b> Files were scanned." + " Results are available at: <b><font face='arial' color='green'>" + $ResultsCSV  + " </font></b> File."
    $SMTPServer = "mail.themdc.net " #"smtp.gmail.com"
    # $SMTPPort = "587"
    Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -BodyAsHtml -port $SMTPPort 
    # -UseSsl -Credential (Get-Credential) -Attachments $Attachment –DeliveryNotificationOption OnSuccess