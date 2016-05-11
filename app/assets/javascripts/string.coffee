String::capitalize = -> @charAt(0).toUpperCase() + @slice(1)
String::singularize = -> @replace(/s$/,'')
