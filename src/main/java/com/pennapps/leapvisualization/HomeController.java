package com.pennapps.leapvisualization;

import java.io.IOException;
import java.text.DateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.servlet.ServletContext;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.pennapps.leapvisualization.model.CrimeEntry;
import com.pennapps.leapvisualization.service.CrimeEntryService;

/**
 * Handles requests for the application home page.
 */
@Controller
public class HomeController {

	private static final Logger logger = LoggerFactory
			.getLogger(HomeController.class);

	@Autowired
	CrimeEntryService crimeEntryService;

	@Autowired
	private ServletContext servletContext;

	/**
	 * Simply selects the home view to render by returning its name.
	 */

	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String home(Locale locale, Model model) {
		logger.info("Welcome home! The client locale is {}.", locale);

		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG,
				DateFormat.LONG, locale);

		String formattedDate = dateFormat.format(date);

		model.addAttribute("serverTime", formattedDate);

		return "home";
	}

	@RequestMapping(value = "/about", method = RequestMethod.GET)
	public String about(Locale locale, Model model) {

		return "about";
	}

	@RequestMapping(value = "/instructions", method = RequestMethod.GET)
	public String instructions(Locale locale, Model model) {

		return "instructions";
	}

	@ResponseBody
	@RequestMapping(value = "/crime-entry", method = RequestMethod.GET)
	public List<CrimeEntry> getCrimeEntries() throws IOException {

		return crimeEntryService.getCrimeEntries();
	}

	@ResponseBody
	@RequestMapping(value = "/bounded-crime-entry", method = RequestMethod.GET)
	public List<CrimeEntry> getBoundedCrimeEntries(
			@RequestParam(value = "x1", required = true) Double x1,
			@RequestParam(value = "y1", required = true) Double y1,
			@RequestParam(value = "x2", required = true) Double x2,
			@RequestParam(value = "y2", required = true) Double y2)
			throws IOException {

		return crimeEntryService.getBoundedCrimeEntries(x1, y1, x2, y2);
	}

	@ResponseBody
	@RequestMapping(value = "/area-count", method = RequestMethod.GET)
	public int[][] getAreaCount(
			@RequestParam(value = "x1", required = true) Double x1,
			@RequestParam(value = "y1", required = true) Double y1,
			@RequestParam(value = "x2", required = true) Double x2,
			@RequestParam(value = "y2", required = true) Double y2,
			@RequestParam(value = "width", required = true) Integer width,
			@RequestParam(value = "height", required = true) Integer height)
			throws IOException {

		return crimeEntryService.getAreaCount(x1, y1, x2, y2, width, height);
	}

	@ResponseBody
	@RequestMapping(value = "/nearst", method = RequestMethod.GET)
	public List<CrimeEntry> getAreaCount(
			@RequestParam(value = "x", required = true) Double x,
			@RequestParam(value = "y", required = true) Double y)
			throws IOException {

		return crimeEntryService.getNearestFromPoint(x, y);
	}

}
