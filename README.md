# openshift-jenkins-slave-geomapfish

This is the builder image code for geomapfish

Initial build was tarted with

```
oc new-build https://github.com/camptocamp/openshift-jenkins-slave-geomapfish.git
```

To see build logs

```
oc logs -f bc/openshift-jenkins-slave-geomapfish
```
