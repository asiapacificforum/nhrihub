// PhantomJS doesn't support bind yet
// should be fixed in PhantomJS 2.0
Function.prototype.bind = Function.prototype.bind || function (thisp) {
    var fn = this;
    return function () {
        return fn.apply(thisp, arguments);
    };
};

