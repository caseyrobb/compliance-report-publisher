#!/bin/bash
set -e

[[ $DEBUG ]] && set -x

umask 0112

HTML_DIRECTORY=/opt/nginx/html

_term() {
  log "Caught SIGTERM"
  log "Stopping nginx"
  killall nginx
  log "Exiting"
  exit 0
}

function log() {
  echo "[$(date)] $@" 1>&2
} # log

function processScans() {
  
  echo "<html lang=\"eni\">
    <head>
      <link rel=\"stylesheet\" href=\"bootstrap/bootstrap.min.css\">
      <title>Scan Results</title>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
      <meta http-equiv="refresh" content="30">
      <style>
        a.list-group-item:hover{
          background: #d5d5ff;
        }
      </style>
    </head>
    <body>
      <h1> Scan Results</h1>
      <div class=\"list-group\">" > ${HTML_DIRECTORY}/index_new.html
  
  
  SCAN_NUMBER=0
  while [ -d ${HTML_DIRECTORY}/${SCAN_NUMBER} ]
  do
    echo "<html lang=\"en\">
      <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel=\"stylesheet\" href=\"../bootstrap/bootstrap.min.css\">
        <title>Scan ${SCAN_NUMBER} Results</title>
	<style>
         .table-striped tbody tr:nth-of-type(odd) {
             background-color: #e4e4e4;
	 }
         .table tbody tr:hover {background-color: #d5d5ff;}
	</style>
      </head>
      <body>
        <h1> Scan ${SCAN_NUMBER} Results</h1>
        <table class=\"table table-striped table-bordered table-hover\">
          <thead>
            <tr>
              <th scope=\"col\">Scan Name</th>
              <th scope=\"col\">Scan Time</th>
              <th scope=\"col\">Report</th>
            </tr>
          </thead>
          <tbody>" > ${HTML_DIRECTORY}/${SCAN_NUMBER}/index_new.html
    
    shopt -s nullglob 
    for f in ${HTML_DIRECTORY}/${SCAN_NUMBER}/*.base64
    do
      name=$(echo "$f" | grep -oP '(?!.*\/)(.*)[-]')
      if [ ! -f ${HTML_DIRECTORY}/${SCAN_NUMBER}/${name}result.html ]
      then
        log "Extracting file $f..."
        base64 -d $f | bunzip2 > ${HTML_DIRECTORY}/${SCAN_NUMBER}/${name}result.xml
    
        log "Converting file $f to html..."
        oscap xccdf generate report ${HTML_DIRECTORY}/${SCAN_NUMBER}/${name}result.xml > ${HTML_DIRECTORY}/${SCAN_NUMBER}/${name}result.html
        rm ${HTML_DIRECTORY}/${SCAN_NUMBER}/${name}result.xml
      fi 
      modified=$(stat $f | grep Modify)
      echo "          <tr><th scope=\"row\">${name}result</th><td>${modified:8}</td><td><a href=\"${name}result.html\">HTML Report</a></td></tr>" >> ${HTML_DIRECTORY}/${SCAN_NUMBER}/index_new.html
    done
    echo "       </tbody></table> 
      </body>
</html>" >> ${HTML_DIRECTORY}/${SCAN_NUMBER}/index_new.html
   
    rm -f ${HTML_DIRECTORY}/${SCAN_NUMBER}/index.html
    mv ${HTML_DIRECTORY}/${SCAN_NUMBER}/index_new.html ${HTML_DIRECTORY}/${SCAN_NUMBER}/index.html
    chmod 444 ${HTML_DIRECTORY}/${SCAN_NUMBER}/index.html
    
    echo "        <a href=\"${SCAN_NUMBER}/index.html\" class="list-group-item list-group-item-action">Scan ${SCAN_NUMBER} HTML Reports</a>" >> ${HTML_DIRECTORY}/index_new.html
  
    
    ((SCAN_NUMBER=SCAN_NUMBER+1))
  done
  
  echo "      </div>
    </body>
</html>" >> ${HTML_DIRECTORY}/index_new.html
   
  rm -f ${HTML_DIRECTORY}/index.html
  mv ${HTML_DIRECTORY}/index_new.html ${HTML_DIRECTORY}/index.html
  chmod 444 ${HTML_DIRECTORY}/index.html
} # processScans

function updateReports() {
log "Checking for new scans..."
while true
do
  sleep 10
  processScans
done
}

function startNginx() {
  log "Starting nginx"
  nginx -c /opt/nginx/nginx.conf
} # startNginx

########
# Main #
########
trap _term SIGTERM
rm -f ${HTML_DIRECTORY}/bootstrap
ln -s /opt/nginx/bootstrap ${HTML_DIRECTORY}/bootstrap
log "Processing existing scans"
processScans
startNginx
updateReports

