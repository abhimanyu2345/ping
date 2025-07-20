import jwt from "jsonwebtoken";
export const decode = (res) => {
    return new Promise((resolve, reject) => {
        var data = "";
        res.onData((chunk, isLast) => {
            data += Buffer.from(chunk).toString();
            if (isLast) {
                try {
                    resolve(JSON.parse(data));
                }
                catch (e) {
                    reject(e);
                }
            }
        });
        res.onAborted(() => {
            reject(new Error("Request was aborted before complete data was received."));
        });
    });
};
export const authenticate = (token) => {
    try {
        const secret_key = 'z3fFP2Wdq1To9+G5TvaGVRe0eN/dXms74uClhfuwyX5fi3vFcz3Q9R+eTHZe6GDI+jCJ/nvHuQhK45ZvQCoY8g==';
        const decoded = jwt.verify(token, secret_key);
        return decoded?.user_metadata?.sub;
    }
    catch (e) {
        console.error(e);
        return null;
    }
};
//# sourceMappingURL=sericve.js.map