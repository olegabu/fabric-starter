
// Important.
// This module should be included as early as possible to provide
// errors catching while bootstrap process is in progress.

// We intentionally implement exception handler as simple as possible.
// Assumed that when exception occurs application is in unstable state
// and we cannot rely on any complex (our or 3rd party) infrastructures
// and perform not trivial DOM manipulation.

// propagate all uncaught errors to our handler
window.onerror = function(msg, url, line) {
   _processError(new Error(msg + '\n' + url + ':' + line));
};

function _processError(error, cause){
   console.error("FATAL", error, cause || '');
   // TODO: add appropriate ui action
}
