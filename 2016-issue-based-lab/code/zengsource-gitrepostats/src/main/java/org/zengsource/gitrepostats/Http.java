/** 
 * 基于GitHub的实验教学代码。<br />
 * By 惠州学院 曾少宁
 */
package org.zengsource.gitrepostats;

import java.io.IOException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.protocol.HttpClientContext;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

/**
 * @author zengsn
 * @since 8.0
 */
public class Http implements Api {
	public static String get(String url) {
		UsernamePasswordCredentials creds = new UsernamePasswordCredentials(USERNAME, TOKEN);
		CredentialsProvider credsProvider = new BasicCredentialsProvider();
		credsProvider.setCredentials(new AuthScope(GIT, 443), creds);
		HttpClientContext context = HttpClientContext.create();
		context.setCredentialsProvider(credsProvider);
		// context.setAuthSchemeRegistry(authRegistry);
		// context.setAuthCache(authCache);
		CloseableHttpClient httpclient = HttpClients.createDefault();
		// 先登录一下
		HttpGet loginGet = new HttpGet(LOGIN);
		// 再查询
		HttpGet httpget = new HttpGet(url);

		System.out.println(httpget.getRequestLine());

		// Create a custom response handler
		ResponseHandler<String> responseHandler = new ResponseHandler<String>() {
			public String handleResponse(final HttpResponse response) throws ClientProtocolException, IOException {
				int status = response.getStatusLine().getStatusCode();
				if (status >= 200 && status < 300) {
					HttpEntity entity = response.getEntity();
					return entity != null ? EntityUtils.toString(entity) : null;
				} else {
					throw new ClientProtocolException("Unexpected response status: " + status);
				}
			}

		};
		try {
			httpclient.execute(loginGet);
			String responseBody = httpclient.execute(httpget, responseHandler, context);
			System.out.println("----------------------------------------");
			System.out.println(responseBody);
			httpclient.close();
			return responseBody;
		} catch (ClientProtocolException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
}
