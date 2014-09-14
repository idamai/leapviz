package com.pennapps.leapvisualization.model;

import java.io.Serializable;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.PersistenceConstructor;
import org.springframework.data.mongodb.core.mapping.Document;

@Document
public class CrimeEntry implements Serializable {

	private static final long serialVersionUID = 2925303568193367785L;

	private String dcDist;

	private String sector;

	private String dispatchDateTime;

	private String hour;

	private String dcKey;

	private String locationBlock;

	private String ucrGeneral;

	@Id
	private String objectId;

	private String textGeneralCode;

	private Double[] location;

	private String shape;

	@PersistenceConstructor
	public CrimeEntry(String dcDist, String sector, String dispatchDateTime,
			String hour, String dcKey, String locationBlock, String ucrGeneral,
			String objectId, String textGeneralCode, Double[] location,
			String shape) {
		this.dcDist = dcDist;
		this.sector = sector;
		this.dispatchDateTime = dispatchDateTime;
		this.hour = hour;
		this.dcKey = dcKey;
		this.locationBlock = locationBlock;
		this.ucrGeneral = ucrGeneral;
		this.objectId = objectId;
		this.textGeneralCode = textGeneralCode;
		this.location = location;
		this.shape = shape;

	}

	public CrimeEntry(String dcDist, String sector, String dispatchDateTime,
			String hour, String dcKey, String locationBlock, String ucrGeneral,
			String objectId, String textGeneralCode, Double pointX,
			Double pointY, String shape) {
		this.dcDist = dcDist;
		this.sector = sector;
		this.dispatchDateTime = dispatchDateTime;
		this.hour = hour;
		this.dcKey = dcKey;
		this.locationBlock = locationBlock;
		this.ucrGeneral = ucrGeneral;
		this.objectId = objectId;
		this.textGeneralCode = textGeneralCode;
		this.location = new Double[] { pointX, pointY };
		this.shape = shape;

	}

	public String getDcDist() {
		return dcDist;
	}

	public String getSector() {
		return sector;
	}

	public String getDispatchDateTime() {
		return dispatchDateTime;
	}

	public String getHour() {
		return hour;
	}

	public String getDcKey() {
		return dcKey;
	}

	public String getLocationBlock() {
		return locationBlock;
	}

	public String getUcrGeneral() {
		return ucrGeneral;
	}

	public String getObjectId() {
		return objectId;
	}

	public String getTextGeneralCode() {
		return textGeneralCode;
	}

	public Double[] getLocation() {
		return location;
	}

	public String getShape() {
		return shape;
	}

}
