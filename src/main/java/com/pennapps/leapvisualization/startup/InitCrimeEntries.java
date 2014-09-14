package com.pennapps.leapvisualization.startup;

import java.io.IOException;
import java.nio.charset.Charset;

import javax.servlet.ServletContext;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.csvreader.CsvReader;
import com.pennapps.leapvisualization.model.CrimeEntry;
import com.pennapps.leapvisualization.service.CrimeEntryService;

@Controller
public class InitCrimeEntries {
	private final String CSV_FILE = "/WEB-INF/classes/police_inct.csv";
	private final char DELIMITER = ',';
	private final Charset CHARSET = Charset.forName("UTF-8");

	@Autowired
	private ServletContext servletContext;

	@Autowired
	CrimeEntryService crimeEntryService;

	private void populateCrimeEntries() throws IOException {

		CsvReader reader = new CsvReader(servletContext.getRealPath(CSV_FILE),
				DELIMITER, CHARSET);
		reader.readHeaders();

		while (reader.readRecord()) {

			String DC_DIST = reader.get("DC_DIST");
			String SECTOR = reader.get("SECTOR");
			String DISPATCH_DATE_TIME = reader.get("DISPATCH_DATE_TIME");
			String HOUR = reader.get("HOUR");
			String DC_KEY = reader.get("DC_KEY");
			String LOCATION_BLOCK = reader.get("LOCATION_BLOCK");
			String UCR_GENERAL = reader.get("UCR_GENERAL");
			String OBJECTID = reader.get("OBJECTID");
			String TEXT_GENERAL_CODE = reader.get("TEXT_GENERAL_CODE");
			Double POINT_X = null;
			String pointXRead = reader.get("POINT_X").trim();
			if (!pointXRead.isEmpty())
				POINT_X = Double.parseDouble(reader.get("POINT_X").trim());
			String pointYRead = reader.get("POINT_Y").trim();
			Double POINT_Y = null;
			if (!pointYRead.isEmpty())
				POINT_Y = Double.parseDouble(reader.get("POINT_Y").trim());
			String SHAPE = reader.get("SHAPE");
			CrimeEntry ce = new CrimeEntry(DC_DIST, SECTOR, DISPATCH_DATE_TIME,
					HOUR, DC_KEY, LOCATION_BLOCK, UCR_GENERAL, OBJECTID,
					TEXT_GENERAL_CODE, POINT_X, POINT_Y, SHAPE);
			crimeEntryService.addCrimeEntry(ce);
		}

	}

	@ResponseBody
	@RequestMapping("/init")
	public String initCrimeEntries() {
		try {
			populateCrimeEntries();
		} catch (IOException e) {
			throw new RuntimeException("Failed to initialize crime entries", e);
		}
		return "DONE";
	}
}
