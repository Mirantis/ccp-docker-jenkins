#! /bin/bash -e

: ${JENKINS_HOME:="/var/jenkins_home"}
touch "${COPY_REFERENCE_FILE_LOG}" || (echo "Can not write to ${COPY_REFERENCE_FILE_LOG}. Wrong volume permissions?" && exit 1)
echo "--- Copying files at $(date)" >> "$COPY_REFERENCE_FILE_LOG"
find /usr/share/jenkins/ref/ -type f -exec bash -c ". /usr/local/bin/jenkins-support; copy_reference_file '{}'" \;

cat /tmp/org.codefirst.SimpleThemeDecorator.xml | envsubst > $JENKINS_HOME/org.codefirst.SimpleThemeDecorator.xml

cat << EOF >>/usr/share/jenkins/ref/init.groovy.d/executors.groovy
import jenkins.model.*
Jenkins.instance.setNumExecutors(${JENKINS_NUM_EXECUTORS:-2})
EOF

# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  eval "exec java $JAVA_OPTS -jar /usr/share/jenkins/jenkins.war $JENKINS_OPTS \"\$@\""
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
