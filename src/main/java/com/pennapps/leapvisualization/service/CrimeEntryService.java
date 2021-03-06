package com.pennapps.leapvisualization.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.pennapps.leapvisualization.model.CrimeEntry;
import com.pennapps.leapvisualization.repository.CrimeEntryRepository;

@Service
public class CrimeEntryService {

	@Autowired
	CrimeEntryRepository crimeEntryRepository;

	public List<CrimeEntry> getCrimeEntries() {
		return crimeEntryRepository.listCrimeEntry();
	}

	public void addCrimeEntry(CrimeEntry crimeEntry) {
		crimeEntryRepository.addCrimeEntry(crimeEntry);
	}

	public List<CrimeEntry> getBoundedCrimeEntries(Double x1, Double y1,
			Double x2, Double y2) {
		return crimeEntryRepository.geoBoundCrimeEntry(x1, y1, x2, y2);
	}

	public int[][] getAreaCount(Double x1, Double y1, Double x2, Double y2,
			Integer width, Integer height) {
		int[][] areaCount = new int[width][height];
		List<CrimeEntry> checkedData = getBoundedCrimeEntries(x1, y1, x2, y2);
		Double xDivider = (x1 - x2) / width.doubleValue();
		Double yDivider = (y1 - y2) / height.doubleValue();
		for (int i = 0; i < checkedData.size(); i++) {
			Double[] current = checkedData.get(i).getLocation();

			int xPos = (int) Math.floor((current[0] - x2) / xDivider);
			int yPos = (int) Math.floor((current[1] - y2) / yDivider);
			areaCount[xPos][yPos]++;
		}
		return areaCount;
	}

	public CrimeEntry getNearestFromPoint(Double x, Double y) {
		List<CrimeEntry> resultList = crimeEntryRepository
				.geoNearestCrimeEntry(x, y);
		if (!resultList.isEmpty()) {
			return resultList.get(0);
		} else
			return null;

	}
}
