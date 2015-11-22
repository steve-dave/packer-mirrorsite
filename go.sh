#!/bin/bash

if [ -z "$1" ]; then
	echo "Must pass site to be mirrored as first parameter"
	exit 1
fi

AMI="$(curl -s4 http://cloud-images.ubuntu.com/locator/ec2/releasesTable | grep '\["ap\-southeast\-2","trusty","14.04 LTS","amd64","hvm:ebs-ssd"' | sed 's/.*\(ami-[a-f0-9]*\).*/\1/')"
SITE="$1"
REVISION="$(git rev-parse HEAD)"
shift

packer build -var "source_ami=${AMI}" -var "site=${SITE}" -var "domain=${SITE#*//}" -var "revision=${REVISION}" "$@" template.json
