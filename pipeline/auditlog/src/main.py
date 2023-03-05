from elasticsearch import Elasticsearch
from datetime import date
import os
import base64
import urllib3
import functions_framework
from concurrent import futures
from google.cloud import pubsub_v1


urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

function_name = os.environ.get("FUNCTION_NAME")
today = date.today()
index_prefix = "INDEX_PREFIX"
index = index_prefix + "-" + str(today)

es_ip = os.environ.get("es_ip")
es_endpoint = "https://" + es_ip + ":9200"
api_key = os.environ.get("es_apikey")
error_topic = os.environ.get("error_topic")

es = Elasticsearch(
    [es_endpoint],
    # basic_auth=(username, password),
    api_key=api_key,
    ssl_show_warn=False,
    verify_certs=False,
)

publisher = pubsub_v1.PublisherClient()
# topic_path = publisher.topic_path(project_id, error_topic)


@functions_framework.cloud_event
def pubsub_to_es(cloud_event):
    doc = base64.b64decode(cloud_event.data["message"]["data"]).decode()
    # doc = {"title": "Hello world"}

    try:
        # write to elasicsearch
        resp = es.index(index=index, document=doc)
    except:
        # if write failed, publish message to Pub/Sub error topic
        future = publisher.publish(error_topic, doc.encode("utf-8"))
        # future.result()

    # print(resp)
