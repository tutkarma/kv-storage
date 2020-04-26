### Simple kv-storage

API

* GET       /kv/<id>
* POST      /kv
    ```json
    {
        "key": "test",
        "value": {SOME ARBITRARY JSON}
    }
    ```
* PUT       /kv/<id>
    ```json
    {
        "value": {SOME ARBITRARY JSON}
    }
    ```
* DELETE    /kv/<id>
