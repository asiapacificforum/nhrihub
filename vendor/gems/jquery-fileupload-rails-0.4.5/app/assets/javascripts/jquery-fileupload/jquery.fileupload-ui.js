/*
 * jQuery File Upload User Interface Plugin 9.6.1
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

/* jshint nomen:false */
/* global define, require, window */

(function ($, _) {
    'use strict';

    $.blueimp.fileupload.prototype._specialOptions.push(
        'filesContainer',
        'uploadTemplateId',
        'downloadTemplateId'
    );

    // The UI version extends the file upload widget
    // and adds complete user interface interaction:
    $.widget('blueimp.fileupload', $.blueimp.fileupload, {

        options: {
            // By default, files added to the widget are uploaded as soon
            // as the user clicks on the start buttons. To enable automatic
            // uploads, set the following option to true:
            autoUpload: false,
            // The ID of the upload template:
            uploadTemplateId: 'template-upload',
            // The ID of the download template:
            downloadTemplateId: 'template-download',
            // The container for the list of files. If undefined, it is set to
            // an element with class "files" inside of the widget element:
            filesContainer: undefined,
            // By default, files are appended to the files container.
            // Set the following option to true, to prepend files instead:
            prependFiles: false,
            // The expected data type of the upload response, sets the dataType
            // option of the $.ajax upload requests:
            dataType: 'json',

            // Translation function, gets the message key to be translated
            // and an object with context specific data as arguments:
            i18n: function (keys, context) {
              var message = locale;
              keys.split('.').forEach(function(c){ message = message[c]})
              if (context) {
                  $.each(context, function (key, value) {
                      message = message.replace('{' + key + '}', value);
                  });
              }
              return message
            },

            // pull the locale string from the url
            current_locale: function(){
              return window.location.pathname.match(/\/(..)\//)[1]
            },

            // Function returning the current number of files,
            // used by the maxNumberOfFiles validation:
            getNumberOfFiles: function () {
                return this.filesContainer.children()
                    .not('.processing').length;
            },

            // Callback to retrieve the list of files from the server response:
            getFilesFromResponse: function (data) {
                if (data.result && $.isArray(data.result.files)) {
                    return data.result.files;
                }
                return [];
            },

            // The add callback is invoked as soon as files are added to the fileupload
            // widget (via file input selection, drag & drop or add API call).
            // See the basic file upload widget for more information:
            add: function (e, data) {
                if (e.isDefaultPrevented()) {
                    return false;
                }
                var $this = $(this), // this is the upload form
                    that = $this.data('blueimp-fileupload') || // $this.data is a jQuery widget
                        $this.data('fileupload'),
                    options = that.options; // options include passed-in options when widget was initialized
                                            // in initialization script on the index page
                                            // merged with default options, above
                data.context = that._renderUpload(data.files) // data.context is the rendered upload template
                    .data('data', data)                       // it has all the data attached to it
                    //.addClass('processing');
                options.uploadTemplateContainer.append(data.context);
                that._forceReflow(data.context);
                that._transition(data.context); // puts the upload template on the page, in the filesContainer
                data.process(function () { // e.g. validation
                    return $this.fileupload('process', data);
                }).always(function () {
                    data.context.each(function (index) {
                        $(this).find('.size').text(
                            that._formatFileSize(data.size)
                        );
                    }).removeClass('processing');
                    that._renderPreviews(data);
                }).done(function () {
                    data.context.find('.start').prop('disabled', false);
                    if ((that._trigger('added', e, data) !== false) &&
                            (options.autoUpload || data.autoUpload) &&
                            data.autoUpload !== false) {
                        data.submit();
                    }
                }).fail(function () { // e.g. validation fail
                    if (data.files.error) {
                        data.context.each(function (index) {
                            var error = data.files[index].error;
                            if (error) {
                                $(this).find('.error').text(error);
                                $(this).find('.start').prop('disabled', true);
                            }
                        });
                    }
                });
            },

            // Callback for the start of each file upload request:
            send: function (e, data) {
                //console.log("sending: "+$(this).data().blueimpFileupload.eventNamespace)
                if (e.isDefaultPrevented()) {
                    return false;
                }
                var that = $(this).data('blueimp-fileupload') ||
                        $(this).data('fileupload');
                if (data.context && data.dataType &&
                        data.dataType.substr(0, 6) === 'iframe') {
                    // Iframe Transport does not support progress events.
                    // In lack of an indeterminate progress bar, we set
                    // the progress to 100%, showing the full animated bar:
                    data.context
                        .find('.progress').addClass(
                            !$.support.transition && 'progress-animated'
                        )
                        .attr('aria-valuenow', 100)
                        .children().first().css(
                            'width',
                            '100%'
                        );
                }
                return that._trigger('sent', e, data);
            },

            // Callback for successful uploads:
            done: function (e, data) {
                if (e.isDefaultPrevented()) {
                    return false;
                }
                // 'this' is the upload form
                var that = $(this).data('blueimp-fileupload') || // $this.data is a jQuery widget
                        $(this).data('fileupload'),
                    current_locale = that.options.current_locale(),
                    getFilesFromResponse = data.getFilesFromResponse ||
                        that.options.getFilesFromResponse,
                    file = data.result; // the json list returned in ajax response
                var ractive = Ractive.getNodeInfo(this).ractive;
                if(typeof ractive != "undefined"){ // a file is being added to a document group
                  ractive.set(file)
                } else { // a new document group has been created
                  window.internal_documents.unshift("files", file)
                }
                data.context.remove()
                that._trigger('completed', e, data);
                that._trigger('finished', e, data);

                // if (data.context) { // data.context is the upload template
                //     data.context.each(function (index) {
                //         //var file = files[index] ||
                //                 //{error: data.i18n(current_locale+'.corporate_services.internal_documents.fileupload.errors.emptyResult')};
                //         deferred = that._addFinishedDeferreds();
                //         that._transition($(this)).done(
                //             function () {
                //                 var node = $(this);
                //                 // if the received id is the same as one of the template-download table.document ids
                //                 // an archive file is being uploaded, so replace the original template-download
                //                 // otherwise append the new file
                //                 var received_group_id = file.document_group_id
                //                 var target_el = $(".panel-heading table.document[data-document_group_id='"+received_group_id+"']")
                //                 if(target_el.length > 0){ // replace it
                //                   template = that._renderDownload(file)
                //                       .replaceAll(target_el.closest('.template-download'));
                //                 }else{ //replace the upload template with the rendered new file
                //                   template = that.options.filesContainer.append(that._renderDownload(file))
                //                 }
                //                 that._forceReflow(template);
                //                 // put the template in the page, and trigger events when the fade transition is complete
                //                 that._transition(template).done(
                //                     function () {
                //                         data.context.remove()
                //                         data.context = $(this);
                //                         that._trigger('completed', e, data);
                //                         that._trigger('finished', e, data);
                //                         deferred.resolve();
                //                     }
                //                 );
                //             }
                //         );
                //     });
                // } else {
                //     template = that._renderDownload(files)[
                //         that.options.prependFiles ? 'prependTo' : 'appendTo'
                //     ](that.options.filesContainer);
                //     that._forceReflow(template);
                //     deferred = that._addFinishedDeferreds();
                //     that._transition(template).done(
                //         function () {
                //             data.context = $(this);
                //             that._trigger('completed', e, data);
                //             that._trigger('finished', e, data);
                //             deferred.resolve();
                //         }
                //     );
                // }
            },

            // Callback for failed (abort or error) uploads:
            fail: function (e, data) {
                if (e.isDefaultPrevented()) {
                    return false;
                }
                var that = $(this).data('blueimp-fileupload') ||
                        $(this).data('fileupload'),
                    current_locale = that.options.current_locale(),
                    template,
                    deferred;
                if (data.context) {
                    data.context.each(function (index) {
                        if (data.errorThrown !== 'abort') {
                            // in the case of a server error, data.files[index] is the file data sent to the server
                            var file = data.files[index];
                            file.error = file.error || data.errorThrown ||
                                data.i18n(current_locale+'.corporate_services.internal_documents.fileupload.errors.unknownError');
                            deferred = that._addFinishedDeferreds();
                            that._transition($(this)).done(
                                function () {
                                    var node = $(this);
                                    template = that._renderDownload(file)
                                        .replaceAll(node);
                                    that._forceReflow(template);
                                    that._transition(template).done(
                                        function () {
                                            data.context = $(this);
                                            that._trigger('failed', e, data);
                                            that._trigger('finished', e, data);
                                            deferred.resolve();
                                        }
                                    );
                                }
                            );
                        } else {
                            deferred = that._addFinishedDeferreds();
                            that._transition($(this)).done(
                                function () {
                                    $(this).remove();
                                    that._trigger('failed', e, data);
                                    that._trigger('finished', e, data);
                                    deferred.resolve();
                                }
                            );
                        }
                    });
                } else if (data.errorThrown !== 'abort') {
                    data.context = that._renderUpload(data.files)[
                        that.options.prependFiles ? 'prependTo' : 'appendTo'
                    ](that.options.filesContainer)
                        .data('data', data);
                    that._forceReflow(data.context);
                    deferred = that._addFinishedDeferreds();
                    that._transition(data.context).done(
                        function () {
                            data.context = $(this);
                            that._trigger('failed', e, data);
                            that._trigger('finished', e, data);
                            deferred.resolve();
                        }
                    );
                } else {
                    that._trigger('failed', e, data);
                    that._trigger('finished', e, data);
                    that._addFinishedDeferreds().resolve();
                }
            },
            // Callback for upload progress events:
            progress: function (e, data) {
                if (e.isDefaultPrevented()) {
                    return false;
                }
                var progress = Math.floor(data.loaded / data.total * 100);
                if (data.context) {
                    data.context.each(function () {
                        $(this).find('.progress')
                            .attr('aria-valuenow', progress)
                            .children().first().css(
                                'width',
                                progress + '%'
                            );
                    });
                }
            },
            // Callback for global upload progress events:
            progressall: function (e, data) {
                if (e.isDefaultPrevented()) {
                    return false;
                }
                var $this = $(this),
                    progress = Math.floor(data.loaded / data.total * 100),
                    globalProgressNode = $this.find('.fileupload-progress'),
                    extendedProgressNode = globalProgressNode
                        .find('.progress-extended');
                if (extendedProgressNode.length) {
                    extendedProgressNode.html(
                        ($this.data('blueimp-fileupload') || $this.data('fileupload'))
                            ._renderExtendedProgress(data)
                    );
                }
                globalProgressNode
                    .find('.progress')
                    .attr('aria-valuenow', progress)
                    .children().first().css(
                        'width',
                        progress + '%'
                    );
            },
            // Callback for uploads start, equivalent to the global ajaxStart event:
            start: function (e) {
                if (e.isDefaultPrevented()) {
                    return false;
                }
                var that = $(this).data('blueimp-fileupload') ||
                        $(this).data('fileupload');
                that._resetFinishedDeferreds();
                that._transition($(this).find('.fileupload-progress')).done(
                    function () {
                        that._trigger('started', e);
                    }
                );
            },
            // Callback for uploads stop, equivalent to the global ajaxStop event:
            stop: function (e) {
                if (e.isDefaultPrevented()) {
                    return false;
                }
                var that = $(this).data('blueimp-fileupload') ||
                        $(this).data('fileupload'),
                    deferred = that._addFinishedDeferreds();
                $.when.apply($, that._getFinishedDeferreds())
                    .done(function () {
                        that._trigger('stopped', e);
                    });
                that._transition($(this).find('.fileupload-progress')).done(
                    function () {
                        $(this).find('.progress')
                            .attr('aria-valuenow', '0')
                            .children().first().css('width', '0%');
                        $(this).find('.progress-extended').html('&nbsp;');
                        deferred.resolve();
                    }
                );
            },
            processstart: function (e) {
                if (e.isDefaultPrevented()) {
                    return false;
                }
                $(this).addClass('fileupload-processing');
            },
            processstop: function (e) {
                if (e.isDefaultPrevented()) {
                    return false;
                }
                $(this).removeClass('fileupload-processing');
            },
            // Callback for file deletion:
            destroy: function (event, data) {
                if (event.isDefaultPrevented()) {
                    return false;
                }
                // TODO later this is much cleaner if the primary objects are document groups and
                // not internal documents with archive arrays
                var ractive = Ractive.getNodeInfo(event.originalEvent.target).ractive;
                var delete_url = ractive.get('url');
                var that = $(event.originalEvent.target).closest('.fileupload').data('blueimpFileupload');
                var data = $.extend(data, that.options, ractive.get(), {type : 'DELETE'}); // b/c ractive may have a type attribute
                var removeNode = function (resp, stat, jqx) {
                      if(jqx.status == 205){ // http 'reset content', delete the document group
                        var index = this.parent.findAllComponents('doc').indexOf(this);
                        this.parent.splice('files',index,1);
                        // TODO need to delegate this to ractive, with a this.remove() method
                      } else if (jqx.status == 200){
                        // the whole document group is replaced
                        // it is returned by the server in resp
                        if(this.findParent('doc')){ //it's an archive file being deleted
                          this.parent.set(resp)
                        } else { // it's a primary file being deleted
                          this.set(resp)
                        }
                      } else {
                        // fail
                        console.log("fail")
                      }};

                  data.url = delete_url;
                  data.dataType = "json";
                  data.context = ractive;
                  // data.statusCode = {205:function(){alert('got 205')}};
                  $.ajax(data).done(removeNode).fail(function () {
                      that._trigger('destroyfailed', event, data);
                  });
            }
        },

        _resetFinishedDeferreds: function () {
            this._finishedUploads = [];
        },

        _addFinishedDeferreds: function (deferred) {
            if (!deferred) {
                deferred = $.Deferred();
            }
            this._finishedUploads.push(deferred);
            return deferred;
        },

        _getFinishedDeferreds: function () {
            return this._finishedUploads;
        },

        // Link handler, that allows to download files
        // by drag & drop of the links to the desktop:
        _enableDragToDesktop: function () {
            var link = $(this),
                url = link.prop('href'),
                name = link.prop('download'),
                type = 'application/octet-stream';
            link.bind('dragstart', function (e) {
                try {
                    e.originalEvent.dataTransfer.setData(
                        'DownloadURL',
                        [type, name, url].join(':')
                    );
                } catch (ignore) {}
            });
        },

        _formatFileSize: function (bytes) {
            if (typeof bytes !== 'number') {
                return '';
            }
            if (bytes >= 1000000000) {
                return (bytes / 1000000000).toFixed(2) + ' GB';
            }
            if (bytes >= 1000000) {
                return (bytes / 1000000).toFixed(2) + ' MB';
            }
            return (bytes / 1000).toFixed(2) + ' KB';
        },

        _formatBitrate: function (bits) {
            if (typeof bits !== 'number') {
                return '';
            }
            if (bits >= 1000000000) {
                return (bits / 1000000000).toFixed(2) + ' Gbit/s';
            }
            if (bits >= 1000000) {
                return (bits / 1000000).toFixed(2) + ' Mbit/s';
            }
            if (bits >= 1000) {
                return (bits / 1000).toFixed(2) + ' kbit/s';
            }
            return bits.toFixed(2) + ' bit/s';
        },

        _formatTime: function (seconds) {
            var date = new Date(seconds * 1000),
                days = Math.floor(seconds / 86400);
            days = days ? days + 'd ' : '';
            return days +
                ('0' + date.getUTCHours()).slice(-2) + ':' +
                ('0' + date.getUTCMinutes()).slice(-2) + ':' +
                ('0' + date.getUTCSeconds()).slice(-2);
        },

        _formatPercentage: function (floatValue) {
            return (floatValue * 100).toFixed(2) + ' %';
        },

        _renderExtendedProgress: function (data) {
            return this._formatBitrate(data.bitrate) + ' | ' +
                this._formatTime(
                    (data.total - data.loaded) * 8 / data.bitrate
                ) + ' | ' +
                this._formatPercentage(
                    data.loaded / data.total
                ) + ' | ' +
                this._formatFileSize(data.loaded) + ' / ' +
                this._formatFileSize(data.total);
        },

        _renderTemplate: function (func, file) {
            if (!func) {
                return $();
            }
            if ( func instanceof Function ){
              var result = func({
                  file: file,
                  formatFileSize: this._formatFileSize,
                  options: this.options
              });
            } else if (func instanceof Object){ // Ractive preparsed template
              var ractive = new Ractive({template : func, data : {file : file}}),
                  result = ractive.toHTML()
            }

            if (result instanceof $) {
                return result;
            }
            return $(this.options.templatesContainer).html(result).children();
        },

        _renderPreviews: function (data) {
            data.context.find('.preview').each(function (index, elm) {
                $(elm).append(data.files[index].preview);
            });
        },

        _renderUpload: function (files) {
            return this._renderTemplate(
                this.options.uploadTemplate,
                files[0]
            );
        },

        _renderDownload: function (file) {
            return this._renderTemplate(
                this.options.downloadTemplate,
                file
            ).find('a[download]').each(this._enableDragToDesktop).end();
        },

        _startHandler: function (e) {
            e.preventDefault();
            var button = $(e.currentTarget),
                template = button.closest('.template-upload'),
                data = template.data('data');
            button.prop('disabled', true);
            if (data && data.submit) {
                data.submit();
            }
        },

        _cancelHandler: function (e) {
            e.preventDefault();
            var template = $(e.currentTarget)
                    .closest('.template-upload,.template-download'),
                data = template.data('data') || {};
            data.context = data.context || template;
            if (data.abort) {
                data.abort();
            } else {
                data.errorThrown = 'abort';
                this._trigger('fail', e, data);
            }
        },

        _deleteHandler: function (e) {
            e.preventDefault();
            var button = $(e.currentTarget);
            this._trigger('destroy', e, $.extend({
                context: button.closest('table.document'),
                type: 'DELETE'
            }, button.data()));
        },

        _forceReflow: function (node) {
            return $.support.transition && node.length &&
                node[0].offsetWidth;
        },

        _transition: function (node) {
            var dfd = $.Deferred();
            // node may be ':visible' with opacity:0
            if ($.support.transition && node.hasClass('fade') && node.is(':visible')) {
                node.bind(
                    $.support.transition.end,
                    function (e) {
                        // Make sure we don't respond to other transitions events
                        // in the container element, e.g. from button elements:
                        if (e.target === node[0]) {
                            node.unbind($.support.transition.end);
                            dfd.resolveWith(node);
                        }
                    }
                ).toggleClass('in');
            } else {
                node.toggleClass('in');
                dfd.resolveWith(node);
            }
            return dfd;
        },

        _initButtonBarEventHandlers: function () {
            var fileUploadButtonBar = this.element.find('.fileupload-buttonbar'),
                filesList = this.options.uploadTemplateContainer;
            this._on(fileUploadButtonBar.find('.start'), {
                click: function (e) {
                    e.preventDefault();
                    filesList.find('.start').click();
                }
            });
            this._on(fileUploadButtonBar.find('.cancel'), {
                click: function (e) {
                    e.preventDefault();
                    filesList.find('.cancel').click();
                }
            });
        },

        _destroyButtonBarEventHandlers: function () {
            this._off(
                this.element.find('.fileupload-buttonbar')
                    .find('.start, .cancel'),
                'click'
            );
        },

        _initEventHandlers: function () {
            this._super();
            //THIS is where multiple events handlers are initialized, creating multiple ajax req for delete button!!
            this._on(this.options.filesContainer, {
                //'click .start': this._startHandler,
                //'click .cancel': this._cancelHandler,
                //'click .delete': this._deleteHandler
            });
            this._on(this.options.uploadTemplateContainer , {
                'click .start': this._startHandler,
            });
            this._initButtonBarEventHandlers();
        },

        _destroyEventHandlers: function () {
            this._destroyButtonBarEventHandlers();
            this._off(this.options.filesContainer, 'click');
            this._super();
        },

        _enableFileInputButton: function () {
            this.element.find('.fileinput-button input')
                .prop('disabled', false)
                .parent().removeClass('disabled');
        },

        _disableFileInputButton: function () {
            this.element.find('.fileinput-button input')
                .prop('disabled', true)
                .parent().addClass('disabled');
        },

        _initTemplates: function () {
            var options = this.options;
            options.templatesContainer = this.document[0].createElement(
                options.filesContainer.prop('nodeName')
            );

            if (options.uploadTemplateContainerId === undefined) {
                options.uploadTemplateContainer = this.element.find('.files');
            } else if (!(options.uploadTemplateContainer instanceof $)) {
                options.uploadTemplateContainer = $(options.uploadTemplateContainerId);
            }

            if (Ractive) { // using Ractive templates
                if (options.uploadTemplateId) {
                    options.uploadTemplate = Ractive.parse($(options.uploadTemplateId).html());
                }
                if (options.downloadTemplateId) {
                    options.downloadTemplate = Ractive.parse($(options.downloadTemplateId).html());
                }
            }
        },

        _initFilesContainer: function () {
            var options = this.options;
            if (options.filesContainer === undefined) {
                options.filesContainer = this.element.find('.files');
            } else if (!(options.filesContainer instanceof $)) {
                options.filesContainer = $(options.filesContainer);
            }
        },

        _initOptions: function(){
          var options = this.options;
          options.acceptFileTypes = new RegExp("\\.("+options.permittedFiletypes.join("|")+")$",'i');
        },

        _initSpecialOptions: function () {
            this._super();
            this._initFilesContainer();
            this._initTemplates();
            this._initOptions();
        },

        _create: function () {
            this._super();
            this._resetFinishedDeferreds();
            if (!$.support.fileInput) {
                this._disableFileInputButton();
            }
        },

        enable: function () {
            var wasDisabled = false;
            if (this.options.disabled) {
                wasDisabled = true;
            }
            this._super();
            if (wasDisabled) {
                this.element.find('input, button').prop('disabled', false);
                this._enableFileInputButton();
            }
        },

        disable: function () {
            if (!this.options.disabled) {
                this.element.find('input, button').prop('disabled', true);
                this._disableFileInputButton();
            }
            this._super();
        }

    });

}( window.jQuery, window._));
