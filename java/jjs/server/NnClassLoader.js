/*
   Copyright 2016 Sergi Vladykin (https://github.com/svladykin) 

   Version 1.3

   The latest version can be found at https://github.com/NashornTools

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
*/


var NnClassLoader = (function () {

var DEBUG = java.lang.Boolean.getBoolean('NnClassLoader.debug');

var MAVEN_VERSION = '3.5.0';
var MAVEN_MD5 = 'c062cb57ca81615cc16500af332b93bd';
var MAVERN_URLS = [
	'http://www-us.apache.org/dist/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.zip',
	'http://www-eu.apache.org/dist/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.zip',
	'https://archive.apache.org/dist/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.zip',
];

var Class = java.lang.Class;
var URL = java.net.URL;
var File = java.io.File;
var Files = java.nio.file.Files;
var SCO = java.nio.file.StandardCopyOption;
var System = java.lang.System;
var Thread = java.lang.Thread;

var JAVA_VERSION = System.getProperty("java.specification.version");

var StaticClass = Java.type(JAVA_VERSION === '1.8' ? 'jdk.internal.dynalink.beans.StaticClass' : 'jdk.dynalink.beans.StaticClass');

var WORK_DIR = path(System.getProperty("user.home"), '.mvn_js');
var MVN = path(WORK_DIR, 'mvn-' + MAVEN_VERSION);
var MVN_HOME = path(MVN, 'apache-maven-' + MAVEN_VERSION);
var MVN_LIB = path(MVN_HOME , 'lib');
var MVN_BOOT = path(MVN_HOME, 'boot');

function path() {
	var args = Array.prototype.slice.call(arguments); // Convert to array.

	return args.join(File.separator);
}

function debug(str) {
	if (DEBUG)
		System.out.println(str);
}

function file(pathStr) {
	return new File(pathStr);
}


function isDefined(o) {
	return typeof(o) !== 'undefined';
}

function isObject(o) { // Will return true for arrays as well. 
	return typeof(o) === 'object';
}

function forEach(obj, fun) {
	for (var i in obj)
		fun(obj[i])
}

function download(url, filePath) {
	var tmpFile = file(filePath + '.tmp');
	var input = null;

	try {
		input = new URL(url).openConnection().getInputStream();

		tmpFile.createNewFile();

		Files.copy(input, tmpFile.toPath(), SCO.REPLACE_EXISTING);
	}
	catch (e) {
		rm(tmpFile);

		throw e;
	}
	finally {
		if (input != null)
			input.close();
	}

	Files.move(tmpFile.toPath(), file(filePath).toPath(), SCO.REPLACE_EXISTING, SCO.ATOMIC_MOVE);
}

function rm(f) {
	if (!f.exists())
		return;

	if (f.isDirectory())
		forEach(f.listFiles(), rm);

	if (!f.delete())
		throw "Failed to delete file: " + f;
}

function unzip(zipFilePath, destDirectory) {
	var ZipInputStream = java.util.zip.ZipInputStream;
	var ZipEntry = java.util.zip.ZipEntry;

	var destDir = file(destDirectory);

	if (!destDir.exists())
		destDir.mkdir();

	var zipIn = new ZipInputStream(Files.newInputStream(file(zipFilePath).toPath()));

	try {
		var entry = zipIn.getNextEntry();

		while (entry != null) {
			var filePath = destDirectory + File.separator + entry.getName();
			if (!entry.isDirectory())
				Files.copy(zipIn, file(filePath).toPath(), SCO.REPLACE_EXISTING);
			else
				file(filePath).mkdir();

			zipIn.closeEntry();
			entry = zipIn.getNextEntry();
		}
	}
	finally {
		zipIn.close();
	}
}

function md5(filePath) {
	var MessageDigest = java.security.MessageDigest;
	var DigestInputStream = java.security.DigestInputStream;

	var md = MessageDigest.getInstance("MD5");
	var stream = new DigestInputStream(Files.newInputStream(file(filePath).toPath()), md);

	while (stream.read() != -1) {}

	return bytesToHex(md.digest());
}

function bytesToHex(b) {
	var Integer = java.lang.Integer;

	var res = '';

	for (var i = 0; i < b.length; i++)
		res += Integer.toString((b[i] & 0xff) + 0x100, 16).substring(1);

	return res;
}

function withOkLock(fun, okFileName) {
	var ok = file(path(WORK_DIR, okFileName));

	if (ok.exists())
		return;

	var workDir = file(WORK_DIR);

	workDir.mkdirs();

	if (!workDir.exists())
		throw "Failed to create directory: " + WORK_DIR;

	var lockFile = file(path(WORK_DIR, ".lock"));

	var RandomAccessFile = java.io.RandomAccessFile;
	var OverlappingFileLockException = java.nio.channels.OverlappingFileLockException;

	var raf = new RandomAccessFile(lockFile, "rw");

	try {
		var lock = null;

		do {
			try {
				lock = raf.getChannel().lock();
			}
			catch(e) {
				if (e instanceof OverlappingFileLockException)
					Thread.sleep(50);
				else
					throw e;
			}
		}
		while (lock === null);

		try {
			// Wait a bit inside of the lock before the double checking to allow the file system to catch up.
			// We need it because file systems have different and usually very wonky concurrent visibility guaranties.
			Thread.sleep(50);

			if (ok.exists())
				return;

			fun();

			ok.createNewFile();
		}
		finally {
			lock.release();
		}
	}
	finally {
		raf.close();
	}
}

function installMaven() {
	var mvnZipPath = MVN + '.zip';
	var zip = file(mvnZipPath);

	var i = 0;

	while (!zip.exists() || md5(mvnZipPath) !== MAVEN_MD5) {
		try {
			if (i >= MAVERN_URLS.length)
				break; // No more URLs.

			var url = MAVERN_URLS[i++];

			debug("Downloading maven from: " + url);

			download(url, mvnZipPath);

			debug("Download complete, running checksum.");

			var md5hash = md5(mvnZipPath);

			if (md5hash === MAVEN_MD5)
				break; // Success.
			else
				throw "Checksum error in " + mvnZipPath + ", expected: " + MAVEN_MD5 + ", actual: " + md5hash;
		}
		catch(e) {
			if (isDefined(e.printStackTrace)) {
				if (DEBUG)
					e.printStackTrace();
			}
			else
				debug("Error: " + e);

			rm(zip);
		}
	}

	if (!zip.exists())
		throw "Failed to download Maven.";

	debug("Unzipping maven into: " + MVN);

	rm(file(MVN));

	unzip(mvnZipPath, MVN);

	debug("Maven sucessfully installed.");
}

function parseMavenDependency(dep) {
	var arr = dep.split(':');
	var res = {};

	res.version = arr.pop();
	res.artifactId = arr.pop();
	res.groupId = arr.pop();

	return res;
}

function generatePomXmlFile(cfg) {
	var dependenciesXml = '';
	forEach(cfg.maven, function (dep) {
		var d = parseMavenDependency(dep);

		dependenciesXml += '' +
'		<dependency>\n' +
'			<groupId>' + d.groupId + '</groupId>\n' +
'			<artifactId>' + d.artifactId + '</artifactId>\n' +
'			<version>' + d.version + '</version>\n' +
'		</dependency>\n';
	});

	var pomXml = '' +
'<?xml version="1.0" encoding="UTF-8"?>\n' +
'<project>\n' +
'	<modelVersion>4.0.0</modelVersion>\n' +
'	<groupId>nashorn.tools</groupId>\n' +
'	<artifactId>tmp</artifactId>\n' +
'	<packaging>pom</packaging>\n' +
'	<version>1.0-SNAPSHOT</version>\n' +
'	<name>tmp</name>\n' +
'	<dependencies>\n' +
		dependenciesXml +
'	</dependencies>\n' +
'</project>\n';


	debug("Generating pom.xml:\n" + pomXml);

	var pom = Files.createTempFile('pom-', '.xml').toAbsolutePath();
	Files.write(pom, pomXml.toString().getBytes('UTF-8'));

	return pom.toFile();
}

function readTextFile(filePath, charset) {
	var Charset = java.nio.charset.Charset;

	var lines = Files.readAllLines(file(filePath).toPath(), Charset.forName(charset));
	var contents = Java.from(lines).join('\n');

	debug("Contents of file '" + filePath + "':\n" + contents);

	return contents;
}

function debugPrintStream() {
	if (DEBUG)
		return System.out;

	var PrintStream = java.io.PrintStream;

	return new PrintStream(function(b) {}, true, 'UTF-8'); // /dev/null
}

function setContextClassLoader(ldr) {
	var th = Thread.currentThread();

	var oldLdr = th.getContextClassLoader();

	th.setContextClassLoader(ldr);

	return oldLdr;
}

function collectMavenDependencies(cfg, urls) {
	withOkLock(installMaven, ".ok-" + MAVEN_VERSION);

	var cp = null;

	var mvnTmp = Files.createTempDirectory("mvn-js-tmpdir-").toFile();

	try {
		// Set system properties for Maven.
		System.setProperty("maven.multiModuleProjectDirectory", mvnTmp.getCanonicalPath())
		System.setProperty("maven.home", file(MVN_HOME).getCanonicalPath());
		System.setProperty("classworlds.conf", file(path(MVN_HOME, 'bin', 'm2.conf')).getCanonicalPath());

		var L = new NnClassLoader({dirs:[MVN_LIB, MVN_BOOT]});

		debug("Maven CLI classpath: " + L.getUrls());

		// Temporary set context class loader to Maven.
		var oldLdr = setContextClassLoader(L.getJavaClassLoader());

		try {
			var MavenCli = L.type('org.apache.maven.cli.MavenCli');

			var cli = new MavenCli();

			var cpFile = Files.createTempFile('cp-', '.txt').toFile();

			try {
				var pomFile = generatePomXmlFile(cfg);

				try {
					var printStream = debugPrintStream();

					var mvnArgs = ['-f', pomFile.getCanonicalPath(), "-Dmdep.outputFile=" + cpFile.getCanonicalPath(),
						'dependency:go-offline', 'dependency:build-classpath', 'verify'];

					if (DEBUG)
						mvnArgs = ['--debug', '--errors'].concat(mvnArgs);

					var exitCode = cli.doMain(mvnArgs, mvnTmp.getCanonicalPath(), printStream, printStream);

					if (exitCode !== 0)
						throw "Exit code of maven " + exitCode;

					cp = readTextFile(cpFile.getCanonicalPath(), 'UTF-8');
				}
				finally {
					rm(pomFile);
				}
			}
			finally {
				rm(cpFile);
			}
		}
		finally {
			setContextClassLoader(oldLdr);
		}
	}
	finally {
		rm(mvnTmp);
	}

	if (cp !== null) {
		forEach(cp.trim().split(File.pathSeparator), function(jar) {
			urls.add(toURL(file(jar)));
		});
	}
}

function loadType(className, ldr) {
	var cls = Class.forName(className, true, ldr);
	return StaticClass.forClass(cls);
}

function toURL(f) {
	return f.getCanonicalFile().toURI().toURL();
}

function scanDirForJars(f, filter, urls) {
	if (!f.exists())
		return;
	if (f.isDirectory()) {
		if (filter(f)) {
			forEach(f.listFiles(), function(x) {
				scanDirForJars(x, filter, urls);
			});
		}
	}
	else if (f.isFile() && f.getName().toLowerCase().endsWith('.jar') && filter(f))
		urls.add(toURL(f));
}

function collectAllJarUrls(cfg) {
	if (!isObject(cfg)) 
		throw "Class loader configuration object is not provided.\nFor example: new NnClassLoader({jars:['/myapp/bla.jar'], urls:['http://.../bla.jar']})";

	var HashSet = java.util.HashSet;
	var UrlArray = Java.type('java.net.URL[]');

	var urls = new HashSet();

	if (isObject(cfg.urls)) {
		forEach(cfg.urls, function(url) {
			urls.add(new URL(url));
		});
	}

	if (isObject(cfg.jars)) {
		forEach(cfg.jars, function(jar) {
			var f = file(jar);

			if (f.isFile())
				urls.add(toURL(f));
		});
	}

	if (isObject(cfg.dirs)) {
		var filter = isDefined(cfg.filter) ? cfg.filter : function(f) {return true;};

		forEach(cfg.dirs, function (dir) {
			scanDirForJars(file(dir), filter, urls);
		});
	}

	if (isObject(cfg.classes)) {
		forEach(cfg.classes, function (dir) {
			var f = file(dir);

			if (f.isDirectory())
				urls.add(toURL(f));
		});
	}

	if (isObject(cfg.maven))
		collectMavenDependencies(cfg, urls);

	return urls.toArray(new UrlArray(0));
}

function NnClassLoader(cfg) {
	var URLClassLoader = java.net.URLClassLoader;

	var jarUrls = collectAllJarUrls(cfg);
	var ldr = isObject(cfg.parent) ? 
		new URLClassLoader(jarUrls, cfg.parent):
		new URLClassLoader(jarUrls);

	this.type = function(className) {
		return loadType(className, ldr);
	}

	this.getUrls = function() {
		var res = [];

		forEach(jarUrls, function (url) {
			res.push(url.toString());
		});

		return res;
	}

	this.getJavaClassLoader = function() {
		return ldr;
	}
}

return NnClassLoader;
})();
