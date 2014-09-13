package com.pennapps.leapvisualization.repository;

import static org.springframework.data.mongodb.core.query.Criteria.where;
import static org.springframework.data.mongodb.core.query.Query.query;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
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
		return mongoTemplate
				.find(query(where("PointX").lt(x1).gt(x2).and("PointY").lt(y1)
						.gt(y2)), CrimeEntry.class, COLLECTION_NAME);
	}
}
