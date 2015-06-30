//This is a very ugly hack!
//it's from http://stackoverflow.com/questions/10839771/jquery-ajaxerror-runs-even-if-the-response-is-ok-200
//when http status code 205 is returned, there is no content from the server
//but jquery is raising an error b/c it tries to parse a blank string
//This hack permits Rails to return a 205 blank response
//and jquery to behave itself
//HACK JSON.parse('') should return undefined, not throw an error
var _parse = JSON.parse
JSON.parse = function(str) {
  if (str !== '')
    return _parse.apply(JSON, arguments);
  else
    return undefined;
}
