# Notes

When the original self signed certificate used for signing the app expired, 
I had to spend a considerable amount of time to correct it.  
There were a number of issues that cropped up when fixing each.  

1. Install Flex Builder 3 Trial version
2. Update the flex compiler properties of the project
 `-locale=en_US,de_DE -allow-source-path-overlap=true  -source-path=locale/{locale}`
3. Install Adobe Air Runtime
4. Use JDK 8 32 bit version to run "copylocale" command to generate de_DE resources
5. Update *app.xml schema version - https://www.techyv.com/questions/error-creating-air-file-305
6. Build an intermediate build without certificate signing - https://community.adobe.com/t5/air/packaging-error-could-not-generate-timestamp/td-p/8611383?page=1
7. Create a new Self Signed Certificate - https://help.adobe.com/en_US/air/build/WS5b3ccc516d4fbf351e63e3d118666ade46-7f74.html
8. Sign the intermediate build with the new certificate and override the service used for generating the timestamp.
`"C:\Softwares\Flex Builder 3\sdks\3.2.0\bin\adt.bat" -sign -storetype pkcs12 -keystore ..\air_self_signed_2021.p12 -tsa "http://sha256timestamp.ws.symantec.com/sha256/timestamp" "TritonPlayer.airi" "TritonPlayer.air"`
