#!/bin/bash
echo 'Logging into oc tool as admin'
oc login -u admin -p admin
echo 'Switching to the openshift project'
oc project openshift
echo 'Creating the image stream for the OpenShift datavirt image'
oc delete is jboss-datavirt63-openshift
oc create -f https://raw.githubusercontent.com/cvanball/jdv-ose-demo/master/extensions/is.json
echo 'Creating the s2i quickstart template. This will live in the openshift namespace and be available to all projects'
oc delete template datavirt63-extensions-support-s2i
oc create -n openshift -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/datavirt/datavirt63-extensions-support-s2i.json
oc login -u developer -p developer
echo 'Creating a new project called jdv-demo'
oc new-project jdv-demo
echo 'Creating a service account and accompanying secret for use by the data virt application'
oc create -f https://raw.githubusercontent.com/cvanball/jdv-ose-demo/master/extensions/datavirt-app-secret.yaml
echo 'Add the role view to the service account under which the pod is running'
oadm policy add-role-to-user view system:serviceaccount:jdv-demo:datavirt-service-account
echo 'Retrieving datasource properties (market data flat file and country list web service hosted on public internet)'
curl https://raw.githubusercontent.com/cvanball/jdv-ose-demo/master/extensions/datasources.properties -o datasources.properties
echo 'Creating a secret around the datasource properties'
oc secrets new datavirt-app-config datasources.properties
echo 'Deploying JDV quickstart template with default values'
oc new-app datavirt63-extensions-support-s2i -p SOURCE_REPOSITORY_URL=https://github.com/cvanball/jdv-ose-demo -p CONTEXT_DIR=vdb -p EXTENSIONS_REPOSITORY_URL=https://github.com/cvanball/jdv-ose-demo -p EXTENSIONS_DIR=extensions -p TEIID_USERNAME=teiidUser -p TEIID_PASSWORD=redhat1!
echo '==============================================='
echo 'The following urls will allow you to access the vdbs (of which there are two) via OData2 and OData4:'
echo '==============================================='
echo 'ODATA 2'
echo 'Metadata for Country web service - http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata/country-ws/$metadata'
echo 'Querying data from Country web service - http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata/country-ws/country.Countries?$format=json'
echo 'Querying data from Country web service via primary key - http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata/country-ws/country.Countries(‘Zimbabwe’)?$format=json'
