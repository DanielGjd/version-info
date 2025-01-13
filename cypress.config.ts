import { defineConfig } from 'cypress';
import { shiftSimulatorPlugin } from './cypress/support/simulator/simulator-plugin';
import { hmiPlugins } from './cypress/support/hmi-plugins';
import { mockServerPlugin } from './cypress/support/mockserver/mockserver';
import Browser = Cypress.Browser;
import BrowserLaunchOptions = Cypress.BrowserLaunchOptions;
import { versionInfoRsiPlugin } from './cypress/support/versionInfoRsiPlugin';

export default defineConfig({
  viewportWidth: 2240,
  viewportHeight: 976,
  taskTimeout: 16000,
  defaultCommandTimeout: 16000,
  video: false,
  reporter: 'cypress-mochawesome-reporter',
  reporterOptions: {
    reportDir: 'tests/e2e',
    charts: true,
    reportPageTitle: 'VersionInfo e2e Test Results',
    embeddedScreenshots: true,
    inlineAssets: true
  },
  e2e: {
    setupNodeEvents(on, config) {
      require('cypress-mochawesome-reporter/plugin')(on);
      hmiPlugins(on);
      shiftSimulatorPlugin(on);
      mockServerPlugin(on);
      versionInfoRsiPlugin(on);

      /** let's increase the browser window size when running headlessly
       * this will produce higher resolution images and videos
       * @see https://on.cypress.io/browser-launch-api
       * @see https://www.cypress.io/blog/2021/03/01/generate-high-resolution-videos-and-screenshots/
       */
      on('before:browser:launch', (browser: Browser, launchOptions: BrowserLaunchOptions) => {
        // the browser width and height we want to get
        // our screenshots and videos will be of that resolution
        // let's set it to 4k
        const width = 3840;
        const height = 2160;

        console.log('setting the browser window size to %d x %d', width, height);

        if (browser.name === 'chrome' && browser.isHeadless) {
          launchOptions.args.push(`--window-size=${width},${height}`);
          // force screen to be non-retina and just use our given resolution
          launchOptions.args.push('--force-device-scale-factor=1');
        }

        return launchOptions;
      });
    }
  }
});
