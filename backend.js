const AWS = require("aws-sdk");

const s3 = new AWS.S3({
	signatureVersion: "v4",
});

const checkAccess = (filename) => {
	// this check depends on your authorization logic
	return true;
};

module.exports.handler = async (event, context) => {
	const filename = event.path.replace(/^\//, ""); // remove leading slash: /book.pdf => book.pdf

	if (checkAccess(filename)) {
		const params = {
			Bucket: process.env.BUCKET,
			Key: filename
		};

		const signedUrl = await s3.getSignedUrlPromise("getObject", params);

		return {
			statusCode: 200,
			headers: {
				// Because the frontend and the API is on different domains we need to add this CORS header
				"Access-Control-Allow-Origin": "*",
			},
			body: signedUrl,
		};
	}else {
		return {
			statusCode: 403,
			body: "Forbidden",
		};
	}
};
