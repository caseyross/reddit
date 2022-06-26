// filesystem
const path = require('path') // node.js built-in API, not part of package.json dependencies
// compilers
const coffeescript = require('coffeescript')
const pugToSvelte = require('pug-to-svelte')
const stylus = require('stylus')
// plugins
const DotEnvFileWebpackPlugin = require('dotenv-webpack')
const HtmlOutputWebpackPlugin = require('html-webpack-plugin')
const HtmlOutputInlineScriptWebpackPlugin = require('html-inline-script-webpack-plugin')

module.exports = {
	entry: {
		preboot: {
			import: './src/preboot.coffee',
		},
		boot: {
			import: './src/boot.coffee',
			dependOn: 'preboot',
		}
	},
	mode: 'production',
	module: {
		rules: [
			{
				test: /\.pug$/,
				use: [{
					loader: 'svelte-loader',
					options: {
						preprocess: [{
							markup: ({ content }) => ({ code: pugToSvelte(content) }),
							script: ({ content }) => ({ code: coffeescript.compile(content, { bare: true }) }),
							style: ({ content }) => ({ code: stylus.render(content) }),
						}]
					},
				}],
			},
			{
				test: /\.coffee$/,
				use: [{
					loader: 'coffee-loader',
					options: {
						bare: true // No isolation IIFE
					}
				}],
			},
			{
				test: /\.styl$/,
				use: [
					{
						loader: 'style-loader'
					},
					{
						loader: 'css-loader'
					},
					{
						loader: 'stylus-loader',
						options: {
							webpackImporter: false // Don't resolve imports at this stage
						}
					},
				],
			},
			{
				test: /\.(woff2|ttf|otf)$/,
				type: 'asset/resource',
			},
		],
	},
	optimization: {
		runtimeChunk: 'single', // with multiple entries on one page, need single runtime chunk to avoid duplicate module instantiations
	},
	output: {
		clean: true, // cleanup local output directory before emitting assets
		filename: '[name].[contenthash].js',
		path: path.join(__dirname, 'dist'), // local filesystem output directory, absolute path required
		publicPath: '/', // location where the browser should look on the webserver to find output assets
	},
	plugins: [
		new DotEnvFileWebpackPlugin(),
		new HtmlOutputWebpackPlugin({
			favicon: './src/ui/product/favicon_16.png',
			inject: false, // manual script placement in template
			publicPath: '/',
			template: './src/ui/infra/index.html',
		}),
		new HtmlOutputInlineScriptWebpackPlugin({
			scriptMatchPattern: [/^runtime/, /^preboot/] // avoid add'l network roundtrip on critical path
		}),
	],
}