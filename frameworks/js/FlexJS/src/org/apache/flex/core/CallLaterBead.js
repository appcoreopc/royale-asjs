/**
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

goog.provide('org_apache_flex_core_CallLaterBead');



/**
 * @constructor
 */
org_apache_flex_core_CallLaterBead = function() {

  /**
   * @private
   * @type {Object}
   */
  this.strand_ = null;

  /**
   * @private
   * @type {Array}
   */
  this.calls_ = null;

};


/**
 * Metadata
 *
 * @type {Object.<string, Array.<Object>>}
 */
org_apache_flex_core_CallLaterBead.prototype.FLEXJS_CLASS_INFO =
    { names: [{ name: 'CallLaterBead.js',
                qName: 'org_apache_flex_core_CallLaterBead'}] };


Object.defineProperties(org_apache_flex_binding_GenericBinding.prototype, {
    'strand': {
        /** @this {org_apache_flex_binding_GenericBinding} */
        set: function(value) {
            if (this.strand_ !== value) {
              this.strand_ = value;
            }
		}
	}
});


/**
 * @param {Function} fn The fucntion to call later.
 * @param {Array=} opt_args The optional array of arguments.
 * @param {Object=} opt_thisArg The optional 'this' object.
 */
org_apache_flex_core_CallLaterBead.prototype.callLater =
    function(fn, opt_args, opt_thisArg) {

  if (this.calls_ == null)
    this.calls_ = [{thisArg: opt_thisArg, fn: fn, args: opt_args }];
  else
    this.calls_.push({thisArg: opt_thisArg, fn: fn, args: opt_args });

  window.setTimeout(goog.bind(this.callback, this), 0);
};


/**
 * @protected
 */
org_apache_flex_core_CallLaterBead.prototype.callback =
    function() {
  var list = this.calls_;
  var n = list.length;
  for (var i = 0; i < n; i++)
  {
     var call = list.shift();
     var fn = call.fn;
     fn.apply(call.thisArg, call.args);
  }
};

