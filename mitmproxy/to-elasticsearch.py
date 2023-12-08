import datetime

from elasticsearch import Elasticsearch
from mitmproxy import http

es = Elasticsearch(['localhost'], port=9200)

def request(flow: http.HTTPFlow) -> None:
    sendDataToEs(index="msteams_request", flow=flow)

def response(flow: http.HTTPFlow) -> None:
    sendDataToEs(index="msteams_response", flow=flow)

def sendDataToEs(index: str, flow: http.HTTPFlow) -> None:
    data = {"url": flow.request.pretty_url,
            "content": flow.request.content.decode(),
            "timestamp": datetime.datetime.utcnow()}
    try:
        es.create(index=index, id=flow.__hash__(), body=data)
        print("send data to es")
    except Exception as e:
        print(e)
        # exit()

