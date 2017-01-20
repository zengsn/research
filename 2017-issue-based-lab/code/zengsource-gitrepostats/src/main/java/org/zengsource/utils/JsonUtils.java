/** 
 * 基于GitHub的实验教学代码。<br />
 * By 惠州学院 曾少宁
 */
package org.zengsource.utils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;

/**
 * @author zengsn
 * @since 8.0
 */
public abstract class JsonUtils {

	public static String toString(Object result) {
		ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
		try {
			return ow.writeValueAsString(result);
		} catch (JsonProcessingException e) {
			e.printStackTrace();
			return "";
		}
	}

	public static List<Map<String, Object>> toList(String json) {
		JsonFactory factory = new JsonFactory();
		ObjectMapper mapper = new ObjectMapper(factory);
		TypeReference<List<Map<String, Object>>> typeRef = //
		new TypeReference<List<Map<String, Object>>>() {
		};
		try {
			List<Map<String, Object>> map = mapper.readValue( //
					new ByteArrayInputStream( //
							json.getBytes("UTF-8")), //
					typeRef);
			return map;
		} catch (JsonParseException e) {
			e.printStackTrace();
		} catch (JsonMappingException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

	public static Map<String, Object> toMap(String json) {
		JsonFactory factory = new JsonFactory();
		ObjectMapper mapper = new ObjectMapper(factory);
		TypeReference<HashMap<String, Object>> typeRef = //
		new TypeReference<HashMap<String, Object>>() {
		};
		try {
			HashMap<String, Object> map = mapper.readValue( //
					new ByteArrayInputStream( //
							json.getBytes("UTF-8")), //
					typeRef);
			return map;
		} catch (JsonParseException e) {
			e.printStackTrace();
		} catch (JsonMappingException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

}
