package com.pennapps.leapvisualization.model;

import java.io.Serializable;

import org.codehaus.jackson.annotate.JsonIgnore;
import org.springframework.data.annotation.Id;
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
	private Double pointX;
	private Double pointY;
	private String shape;

	@JsonIgnore
	public String getDcDist() {
		return dcDist;
	}

	public void setDcDist(String dcDist) {
		this.dcDist = dcDist;
	}

	@JsonIgnore
	public String getSector() {
		return sector;
	}

	public void setSector(String sector) {
		this.sector = sector;
	}

	@JsonIgnore
	public String getDispatchDateTime() {
		return dispatchDateTime;
	}

	public void setDispatchDateTime(String dispatchDateTime) {
		this.dispatchDateTime = dispatchDateTime;
	}

	@JsonIgnore
	public String getHour() {
		return hour;
	}

	public void setHour(String hour) {
		this.hour = hour;
	}

	@JsonIgnore
	public String getDcKey() {
		return dcKey;
	}

	public void setDcKey(String dcKey) {
		this.dcKey = dcKey;
	}

	@JsonIgnore
	public String getLocationBlock() {
		return locationBlock;
	}

	public void setLocationBlock(String locationBlock) {
		this.locationBlock = locationBlock;
	}

	@JsonIgnore
	public String getUcrGeneral() {
		return ucrGeneral;
	}

	public void setUcrGeneral(String ucrGeneral) {
		this.ucrGeneral = ucrGeneral;
	}

	@JsonIgnore
	public String getObjectId() {
		return objectId;
	}

	public void setObjectId(String objectId) {
		this.objectId = objectId;
	}

	@JsonIgnore
	public String getTextGeneralCode() {
		return textGeneralCode;
	}

	public void setTextGeneralCode(String textGeneralCode) {
		this.textGeneralCode = textGeneralCode;
	}

	public Double getPointX() {
		return pointX;
	}

	public void setPointX(Double pointX) {
		this.pointX = pointX;
	}

	public Double getPointY() {
		return pointY;
	}

	public void setPointY(Double pointY) {
		this.pointY = pointY;
	}

	@JsonIgnore
	public String getShape() {
		return shape;
	}

	public void setShape(String shape) {
		this.shape = shape;
	}

}
