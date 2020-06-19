# OpenShift 4.x Complance Operator Demo

## Deploy the operator
Check https://github.com/openshift/compliance-operator for latest directions

```
git clone https://github.com/openshift/compliance-operator.git
cd compliance-operator
oc create -f deploy/ns.yaml
oc project openshift-compliance
cat deploy/ns.yaml
for f in $(ls -1 deploy/crds/*crd.yaml); do oc apply -f $f -n openshift-compliance; done
oc apply -n openshift-compliance -f deploy/

```

## Scanning Demo

1. Scan all of the Red Hat CoreOS (RHCOS) nodes
```
export NAMESPACE=openshift-compliance
oc create -n $NAMESPACE -f compliancesuite_cr.yml

# Watch the pods (takes about 5 minutes for scans to complete and results to be aggregated)
watch oc get -n $NAMESPACE pods

2. When the scan is done, the operator changes the state of the ComplianceSuite object to "Done" and all the pods are transition to the "Completed" state. You can then check the *ComplianceRemediations* that were found with:
```
oc get -n $NAMESPACE complianceremediations
```

4. To apply a remediation, edit that object and set its Apply attribute to true:
```
oc edit -n $NAMESPACE complianceremediation/workers-scan-no-direct-root-logins

# Wait for nodes to reboot
oc get nodes

```


