String::capitalize = -> @charAt(0).toUpperCase() + @slice(1)
String::singularize = -> @replace(/s$/,'')
String::downcase = -> @charAt(0).toLowerCase() + @slice(1)
