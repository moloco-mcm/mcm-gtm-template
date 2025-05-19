___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "MCM User Event API",
  "categories": ["ATTRIBUTION", "ADVERTISING","CONVERSIONS"]
  "brand": {
    "id": "MOLOCO",
    "displayName": "MOLOCO"
  },
  "description": "",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "api_key",
    "displayName": "MCM user event api key",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "api_url",
    "displayName": "MCM api url",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "id",
    "displayName": "event id",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "timestamp",
    "displayName": "timestamp",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "event_type",
    "displayName": "event type",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "channel_type",
    "displayName": "channel type",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "user_id",
    "displayName": "user id",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "page_id",
    "displayName": "page id",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "items",
    "displayName": "items",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "currency",
    "displayName": "currency",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "value",
    "displayName": "total value(revenue)",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "search_term",
    "displayName": "search_term",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "persistent_id",
    "displayName": "persistent_id",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "os",
    "displayName": "os",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

const sendHttpRequest = require('sendHttpRequest');
const setResponseBody = require('setResponseBody');
const setResponseHeader = require('setResponseHeader');
const setResponseStatus = require('setResponseStatus');
const logToConsole = require('logToConsole');
const JSON = require('JSON');

// capture values of template fields
const apiUrl = data.api_url;
const key = data.api_key;

const jsonPayloadObject = {
  event_type: data.event_type,
  channel_type: data.channel_type,
  id: data.id,
  user_id: data.user_id,
  page_id: data.page_id,
  timestamp: data.timestamp,
//device info by OS and persistent_id from template fields
  device: {
    os: data.os,
    persistent_id: data.persistent_id
  }
};

// Add the `items` field 
if (data.event_type == "ADD_TO_CART" || data.event_type == "ADD_TO_WISHLIST") {
  jsonPayloadObject.items = data.items.map(function(item) {
    const itemObject = {
      quantity: item.quantity,
      id: item.item_id
    };
    if (item.price !== undefined) {
      itemObject.price = {
        currency: data.currency,
        amount: item.price
      };
    }
    return itemObject;
  });
}
// Add the `items` field only with item_id
if (data.event_type == "VIEW_ITEM") {
  logToConsole('Item page view being handled', data.items);
  jsonPayloadObject.event_type = 'ITEM_PAGE_VIEW';
  jsonPayloadObject.items = data.items.map(function(item) {
    
    return {
      id: item.item_id
    };
  });
}
// Add the `items` field with 'revenue' field
if (data.event_type == "PURCHASE") {
  jsonPayloadObject.items = data.items.map(function(item) {
    return {
      price: {
        currency: data.currency,
        amount: item.price
      },
      quantity: item.quantity,
      id: item.item_id
    };
  });
  jsonPayloadObject.revenue = {
    currency: data.currency,
    amount: data.value
  };
}
// Add the `search_query` field 
if (data.event_type == "SEARCH") {
  jsonPayloadObject.search_query = data.search_term;
}
//event_type: HOME, PAGEVIEW goes without additional payload

// Convert the object to JSON string
const jsonPayload = JSON.stringify(jsonPayloadObject, null, 2);

logToConsole('JSON body', jsonPayload);

const apiMethod = 'POST';     
const headers = {
  'Content-Type': 'application/json',
  'X-API-Key': key  // Api key
};

// Send the HTTP request using sendHttpRequest 
sendHttpRequest(apiUrl, {
  headers: headers,
  method: apiMethod,
  timeout: 1000
}, jsonPayload).then((result) => {
  const statusCode = result.statusCode;
  const responseBody = result.responseText;

  if (statusCode >= 200 && statusCode < 300) {
    logToConsole('API call successful', responseBody);
    data.gtmOnSuccess();
  } else {
    logToConsole('API call failed with status', statusCode, responseBody);
    data.gtmOnFailure();
  }
}).catch((error) => {
  logToConsole('HTTP request error', error);
  data.gtmOnFailure();
});


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://evt-sel.rmp-api.moloco.com/rmp/event/v1/platforms/MOLOCO_SHOP_DEMO/userevents"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 5/15/2025, 2:06:56 PM


