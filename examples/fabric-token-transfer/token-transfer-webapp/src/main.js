import environment from './environment';
import {ValidationMessageProvider} from 'aurelia-validation';
import {I18N, Backend, TCustomAttribute} from 'aurelia-i18n';
import {PLATFORM, LogManager} from 'aurelia-framework';
import {ConsoleAppender} from 'aurelia-logging-console';

LogManager.addAppender(new ConsoleAppender());
LogManager.setLevel(LogManager.logLevel.warn);

// import {TCustomAttribute} from 'aurelia-i18n';
// import Backend from 'i18next-xhr-backend';

export function configure(aurelia) {
  aurelia.use
  .standardConfiguration()
  //.plugin(PLATFORM.moduleName('aurelia-fontawesome'))

  .plugin('aurelia-i18n', (instance) => {
    let aliases = ['t', 'i18n'];
    // add aliases for 't' attribute
    TCustomAttribute.configureAliases(aliases);

    // register backend plugin
    instance.i18next.use(Backend.with(aurelia.loader));
    // instance.i18next.use(Backend);

    return instance.setup({
      backend: {                                  // <-- configure backend settings
        loadPath: './locales/{{lng}}/{{ns}}.json', // <-- XHR settings for where to get the files from
      },
      attributes: aliases,
      lng: 'en',
      fallbackLng: 'en',
      debug: false
    });
  })
  .plugin('aurelia-table')
  .plugin('aurelia-validation')
  .feature('resources');

  aurelia.use.plugin('aurelia-bootstrap-datetimepicker', config => {
    config.extra.bootstrapVersion = 4;

    // you can also change the button class, default is shown below
    config.extra.buttonClass = 'btn btn-outline-secondary';
  });


  // ValidationMessageProvider.prototype.getMessage = function(key) {
  //   const i18n = aurelia.container.get(I18N);
  //   const translation = i18n.tr(`errorMessages.${key}`);
  //   return this.parser.parse(translation);
  // };
  //
  // ValidationMessageProvider.prototype.getDisplayName = function(propertyName, displayName) {
  //   if (displayName !== null && displayName !== undefined) {
  //     return displayName;
  //   }
  //   const i18n = aurelia.container.get(I18N);
  //   return i18n.tr(propertyName);
  // };

  if (environment.debug) {
    aurelia.use.developmentLogging();
  }

  if (environment.testing) {
    aurelia.use.plugin('aurelia-testing');
  }

  aurelia.start().then(() => {
    let isLoggedIn = localStorage.getItem('jwt');
    if (isLoggedIn) {
      aurelia.setRoot();
    }
    else {
      aurelia.setRoot('login');
    }
  });
}
