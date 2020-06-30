# OpenShift 4.x Complance Operator Demo

## Deploy the compliance operator
Check https://github.com/openshift/compliance-operator for latest directions

```
git clone https://github.com/openshift/compliance-operator.git
cd compliance-operator
git checkout release-4.5 # This version is working for OCP 4.4
```
**NOTE:** Update deploy/operator.yaml to operator version 0.1.9 instead of latest - Latest version is currently not working in OCP 4.4 as of 7/6/2020
```
oc create -f deploy/ns.yaml
oc project openshift-compliance
for f in $(ls -1 deploy/crds/*crd.yaml); do oc apply -f $f -n openshift-compliance; done
oc apply -n  openshift-compliance -f deploy/

# Wait for operator pods to be available
watch oc get pods -n openshift-compliance

```

## Scanning Demo

1. Scan all of the Red Hat CoreOS (RHCOS) worker nodes
```
export NAMESPACE=openshift-compliance
oc create -n $NAMESPACE -f rhcos-compliancesuite_cr.yml

# Watch the pods (takes about 5 minutes for scans to complete and results to be aggregated)
watch oc get -n $NAMESPACE pods
```

or watch the status of the compliancesuite and wait for the status to transition to **DONE**
```
watch oc get compliancesuite
```
2. Deploy the html publisher and navigate to the route that is printed
```
./publish-results.sh rhcos-workers-scan
```

3. When the scan is done, the operator changes the state of the ComplianceSuite object to "Done" and all the pods are transitioned to the "Completed" state. You can then check the *ComplianceRemediations* that were found with:
```
oc get -n $NAMESPACE complianceremediations
```

4. To apply a remediation, edit that object and set its Apply attribute to true
```
oc edit -n $NAMESPACE complianceremediation/rhcos-workers-scan-no-direct-root-logins

# Wait for nodes to reboot
watch oc get nodes

```
5. Verify the remediation was applied
```
oc get complianceremediation rhcos-workers-scan-sshd-set-keepalive
```

## About the HTML publisher

The HTML publisher deploys an nginx pod that contains additional scripts that check for new ARF results, convert those to html via xsl, then publish them to as simple web page. The publisher pod is pulled from quay, however the Dockerfile and supporting content is in the compliance-results-publisher directory and can be built via:
```
podman build -t compliance-results-publisher compliance-results-publisher
```

The container image can be pushed to a registry. Update the following line in the deployment to override the default image with youre newly pushed custom image:
```
      - image: quay.io/kmendez/compliance-results-publisher
```

Run the `publish-results.sh` script after creating the compliance suite, passing it space separated names of the scan(s) defined within your compliance suite.  The script will mount each of the scan PVCs to a separated pod, each of which will convert and publish the html results

### Future Enhancements
Mount all PVCs to a single pod

