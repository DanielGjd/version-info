/** @type {import('ts-jest/dist/types').InitialOptionsTsJest} */

const esModules = ['@angular', '@ngrx', 'three', 'rxjs', 'tslib'];

module.exports = {
  preset: 'jest-preset-angular',
  roots: ['projects'],
  setupFilesAfterEnv: ['<rootDir>/projects/foreground/src/setup-jest.ts'],
  moduleNameMapper: {
    '^i18n/(.*)$': '<rootDir>/projects/i18n/$1'
  },
  extensionsToTreatAsEsm: ['.ts'],
  moduleDirectories: ['node_modules', '/'],
  moduleFileExtensions: ['ts', 'html', 'js', 'json', 'mjs'],
  modulePaths: ['<rootDir>'],
  globalSetup: 'jest-preset-angular/global-setup',
  globals: {
    'ts-jest': {
      tsconfig: '<rootDir>/tsconfig.spec.json',
      stringifyContentPathRegex: '\\.(html|svg)$',
      isolatedModules: true
    }
  },
  transform: {
    '^.+\\.(ts|mjs|js|html)$': 'jest-preset-angular'
  },
  transformIgnorePatterns: [`/node_modules/(?!.*\\.mjs$|${esModules.join('|')})`],
  watchPlugins: ['jest-watch-typeahead/filename', 'jest-watch-typeahead/testname'],
  coverageReporters: ['html', 'text-summary', 'cobertura', 'lcov', 'clover'],
  collectCoverage: true,
  coverageDirectory: './tests/coverage',
  testResultsProcessor: 'jest-sonar-reporter',
  reporters: [
    'default',
    ['jest-junit', { outputDirectory: 'tests/junit', outputName: 'junit_report.xml' }],
    [
      './node_modules/jest-html-reporter',
      { pageTitle: 'VersionInfo Test Report', outputPath: './tests/test-report.html' }
    ]
  ],
  snapshotSerializers: [
    'jest-preset-angular/build/serializers/no-ng-attributes',
    'jest-preset-angular/build/serializers/ng-snapshot',
    'jest-preset-angular/build/serializers/html-comment'
  ],
  collectCoverageFrom: ['projects/foreground/**/*.{ts,html}'],
  coveragePathIgnorePatterns: [
    'projects/foreground/src/environments/',
    'projects/foreground/src/fakes/',
    'projects/foreground/src/polyfills.ts',
    'projects/foreground/src/app/app.module.ts',
    'projects/foreground/src/main.ts',
    'projects/foreground/src/mockserver/mockserver.ts',
    'projects/foreground/src/app/modules/info/services/states/SpecHelper.ts'
  ],
  testPathIgnorePatterns: ['<rootDir>/node_modules/', '<rootDir>/dist/'],
  coverageProvider: 'v8'
};
