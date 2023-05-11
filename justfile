default:
    @just --list

deploy:
    deploy --skip-checks --targets ".#platy" ".#kables" ".#jables" ".#ljesus" ".#belakay"

sdeploy server:
    deploy --skip-checks ".#{{server}}"
