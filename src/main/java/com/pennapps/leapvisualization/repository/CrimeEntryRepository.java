package com.pennapps.leapvisualization.repository;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.geo.Box;
import org.springframework.data.geo.Circle;
import org.springframework.data.geo.Point;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import com.pennapps.leapvisualization.model.CrimeEntry;

@Repository
public class CrimeEntryRepository {

	@Autowired
	private MongoTemplate mongoTemplate;

	public static final String COLLECTION_NAME = "crime_entry";

	public void addCrimeEntry(CrimeEntry crimeEntry) {
		if (!mongoTemplate.collectionExists(CrimeEntry.class)) {
			mongoTemplate.createCollection(CrimeEntry.class);
		}
		mongoTemplate.insert(crimeEntry, COLLECTION_NAME);
	}

	public List<CrimeEntry> listCrimeEntry() {
		return mongoTemplate.findAll(CrimeEntry.class, COLLECTION_NAME);
	}

	public void deleteCrimeEntry(CrimeEntry crimeEntry) {
		mongoTemplate.remove(crimeEntry, COLLECTION_NAME);
	}

	public void updateCrimeEntry(CrimeEntry crimeEntry) {
		mongoTemplate.insert(crimeEntry, COLLECTION_NAME);
	}

	public List<CrimeEntry> geoBoundCrimeEntry(Double x1, Double y1, Double x2,
			Double y2) {
		Box box = new Box(new Point(x2, y2), new Point(x1, y1));
		return mongoTemplate.find(
				new Query(Criteria.where("location").within(box)),
				CrimeEntry.class, COLLECTION_NAME);
	}

	public List<CrimeEntry> geoNearestCrimeEntry(Double x, Double y) {
		Circle circle = new Circle(x, y, 0.00005);
		return mongoTemplate.find(new Query(Criteria.where("location")
				.withinSphere(circle)), CrimeEntry.class, COLLECTION_NAME);
	}
}
