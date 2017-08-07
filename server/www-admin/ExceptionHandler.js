
// Important.
// This module should be included as early as possible to provide
// errors catching while bootstrap process is in progress.

// We intentionally implement exception handler as simple as possible.
// Assumed that when exception occurs application is in unstable state
// and we cannot rely on any complex (our or 3rd party) infrastructures
// and perform not trivial DOM manipulation.

// https://developer.mozilla.org/en/docs/Web/API/GlobalEventHandlers/onerror

// propagate all uncaught errors to our handler
window.onerror = function(msg, url, line, colno, error) {
  // this variant shows syntax error with the error source
  _processError(/*error ||*/ new Error(msg + '\n' + url + ':' + line + (colno ? ':'+colno : '') ));
  return true; // When the function returns true, this prevents the firing of the default event handler.
};

function _processError(error){
   console.error("FATAL", error);
   alert("FATAL: " + error);

   // TODO: make separate fatal handler
   // document.addEventListener('DOMContentLoaded', function(){
   //    globalErrorHandler(error);
   // });
}
