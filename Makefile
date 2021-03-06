.EXPORT_ALL_VARIABLES:

MODEL=randomforest
VERSION=v1.0
IMAGE_TAG=${MODEL}-${VERSION}
PORT=8080
ENDPOINT=http://localhost:${PORT}/v1/models/${MODEL}:predict
CONTAINER_NAME=inference-service
INPUT=input.json
OUTPUT=predictions.json

setup:
	pip install -r requirements.txt

train:
	PYTHONPATH=. python bin/train.py

build:
	docker build -f Dockerfile -t ${IMAGE_TAG} .

train-in-container: build
	-docker rm ${CONTAINER_NAME}
	docker run -it \
		--name ${CONTAINER_NAME} \
		-v $(CURDIR)/outputs:/root/outputs \
		-e "PYTHONPATH=." \
		${IMAGE_TAG} \
		python bin/train.py

run: build
	-docker rm ${CONTAINER_NAME}
	docker run --name ${CONTAINER_NAME} -it -p 8080:${PORT} ${IMAGE_TAG}

serve:
	PYTHONPATH=. python bin/kfserver.py

request:
	curl -X POST ${ENDPOINT} -H "Content-Type: application/json" -d @${INPUT} > ${OUTPUT}