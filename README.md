### Simple kv-storage

API

* GET       /kv/{id}
* POST      /kv
    ```
    {
        "key": "test",
        "value": {SOME ARBITRARY JSON}
    }
    ```
* PUT       /kv/{id}
    ```
    {
        "value": {SOME ARBITRARY JSON}
    }
    ```
* DELETE    /kv/{id}
