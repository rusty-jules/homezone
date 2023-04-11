default:
    @just --list

deploy:
    deploy --skip-checks --targets ".#platy" ".#kables" ".#jables"
