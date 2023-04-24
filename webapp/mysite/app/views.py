from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
import couchdb
from . import response_result

# Create your views here.


COUCHDB_SERVER = "http://localhost:5984"


# Create your views here.
@csrf_exempt
def index(request):
    # connect to couchdb
    couch = couchdb.Server(url=COUCHDB_SERVER)
    version = couch.version()
    couch.resource.credentials = ("admin", "password")
    # create a database
    # db = couch.create("my_couchdb")
    response = JsonResponse({"status": "ok", "version": version})
    response["Access-Control-Allow-Origin"] = "http://localhost:3000"
    return response


@csrf_exempt
def getDetils(request):
    print(request)
    data = {"details": "hello"}
    return response_result.ok("", data)
