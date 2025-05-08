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

// Include device info (OS and persistent_id) from template fields
  device: {
    os: data.os,
    persistent_id: data.persistent_id
  }
};

logToConsole('Event type', data.event_type);

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

const apiMethod = 'POST';     // Set the request method (GET, POST, etc.)
const headers = {
  'Content-Type': 'application/json',
  'X-API-Key': key  // Example header for API key
};

logToConsole('currency data from ecommerce variable', data.ecommerce);
// Send the HTTP request using sendHttpRequest with retry logic
const maxRetries = 2;
const retryDelay = 0; // No delay due to GTM constraints

function sendWithRetry(retriesLeft) {
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
      if (retriesLeft > 0) {
        logToConsole('Retrying... attempts left:', retriesLeft);
        sendWithRetry(retriesLeft - 1);
      } else {
        data.gtmOnFailure();
      }
    }
  }).catch((error) => {
    logToConsole('HTTP request error', error);
    if (retriesLeft > 0) {
      logToConsole('Retrying due to error... attempts left:', retriesLeft);
      sendWithRetry(retriesLeft - 1);
    } else {
      data.gtmOnFailure();
    }
  });
}

sendWithRetry(maxRetries);
