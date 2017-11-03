PATH=/opt/confluent/bin:$PATH
export PATH
MANPATH=/opt/confluent/share/man:$MANPATH
export MANPATH
# The aliases below are to signify that file globbing is unwelcome at the shell
# this avoids a problem if a user does a noderange like 'n[21-33] and there is a file
# in the directory like 'n3' that causes the parameter to change and target a totally
# different node
alias confetty='set -f;confetty';confetty(){ command confetty "$@"; set +f;}
alias nodeattrib='set -f;nodeattrib';nodeattrib(){ command nodeattrib "$@"; set +f;}
alias nodeboot='set -f;nodeboot';nodeboot(){ command nodeboot "$@"; set +f;}
alias nodeconsole='set -f;nodeconsole';nodeconsole(){ command nodeconsole "$@"; set +f;}
alias nodedefine='set -f;nodedefine';nodedefine(){ command nodedefine "$@"; set +f;}
alias nodeeventlog='set -f;nodeeventlog';nodeeventlog(){ command nodeeventlog "$@"; set +f;}
alias nodefirmware='set -f;nodefirmware';nodefirmware(){ command nodefirmware "$@"; set +f;}
alias nodegroupattrib='set -f;nodegroupattrib';nodegroupattrib(){ command nodegroupattrib "$@"; set +f;}
alias nodehealth='set -f;nodehealth';nodehealth(){ command nodehealth "$@"; set +f;}
alias nodeidentify='set -f;nodeidentify';nodeidentify(){ command nodeidentify "$@"; set +f;}
alias nodeinventory='set -f;nodeinventory';nodeinventory(){ command nodeinventory "$@"; set +f;}
alias nodelist='set -f;nodelist';nodelist(){ command nodelist "$@"; set +f;}
alias nodepower='set -f;nodepower';nodepower(){ command nodepower "$@"; set +f;}
alias nodereseat='set -f;nodereseat';nodereseat(){ command nodereseat "$@"; set +f;}
alias noderun='set -f;noderun';noderun(){ command noderun "$@"; set +f;}
alias nodesensors='set -f;nodesensors';nodesensors(){ command nodesensors "$@"; set +f;}
alias nodesetboot='set -f;nodesetboot';nodesetboot(){ command nodesetboot "$@"; set +f;}
alias nodeshell='set -f;nodeshell';nodeshell(){ command nodeshell "$@"; set +f;}
