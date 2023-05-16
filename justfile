default:
    @just --list

deploy:
    deploy --skip-checks --targets --confirm-timeout "65535" ".#platy" ".#kables" ".#jables" ".#ljesus" ".#belakay"

# need to bump up timeout for k3s which can take a long time
sdeploy server timeout="65535":
    deploy --skip-checks --confirm-timeout "{{timeout}}" ".#{{server}}"}
