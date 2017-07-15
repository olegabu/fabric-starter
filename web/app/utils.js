/**
 * Synchronous version of Promise.always()
 * @param {function(err:Error, data:any)} onResolveOrRejectFn
 */
Promise.prototype.always = function(onResolveOrRejectFn){
  return this.catch(function(error){
    onResolveOrRejectFn(error);
    throw error;
  }).then(function(result){
    onResolveOrRejectFn(null, result);
    return result;
  });
};