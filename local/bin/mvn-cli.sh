docker run --rm  -v  $PWD:/usr/src -w /usr/src allin-web:build-artifact-1 mvn -DskipStandalone=false clean package
