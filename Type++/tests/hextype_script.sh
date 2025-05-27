#!/bin/bash


# Assuming your file is named test_files.txt

echo "Running HexType"
input_file="test_files.txt"

docker build -t test_image .
docker run -it  --name=test_name test_image /bin/bash -c "cd /HexType && python3.8 run_test.py -hextype"
container_id=$(docker inspect -f   '{{.Id}}'  test_name)
echo $container_id
while IFS= read -r line
do
    echo "Dowloading: $line"
    docker cp $container_id:/HexType/$line ./

done < "$input_file"

echo "Removing container"
docker stop test_name
docker rm test_name
docker rmi test_image:latest -f
