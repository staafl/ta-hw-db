SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `University` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `University` ;

-- -----------------------------------------------------
-- Table `University`.`Universities`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `University`.`Universities` (
  `UniversityID` INT NULL ,
  `Name` VARCHAR(45) NULL ,
  PRIMARY KEY (`UniversityID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `University`.`Faculties`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `University`.`Faculties` (
  `FacultyID` INT NULL ,
  `Name` VARCHAR(45) NULL ,
  `UniversityID` INT NULL ,
  PRIMARY KEY (`FacultyID`) ,
  INDEX `UniversityID_idx` (`UniversityID` ASC) ,
  CONSTRAINT `UniversityID`
    FOREIGN KEY (`UniversityID` )
    REFERENCES `University`.`Universities` (`UniversityID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `University`.`Departments`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `University`.`Departments` (
  `DepartmentID` INT NULL ,
  `Name` VARCHAR(45) NULL ,
  `FacultyID` INT NULL ,
  PRIMARY KEY (`DepartmentID`) ,
  INDEX `FacultyID_idx` (`FacultyID` ASC) ,
  CONSTRAINT `FacultyID`
    FOREIGN KEY (`FacultyID` )
    REFERENCES `University`.`Faculties` (`FacultyID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `University`.`Students`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `University`.`Students` (
  `StudentID` INT NULL ,
  `Name` VARCHAR(45) NULL ,
  `CourseID` INT NULL ,
  `FacultyID` INT NULL ,
  PRIMARY KEY (`StudentID`) ,
  INDEX `FacultyID_idx` (`FacultyID` ASC) ,
  CONSTRAINT `FacultyID`
    FOREIGN KEY (`FacultyID` )
    REFERENCES `University`.`Faculties` (`FacultyID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `University`.`Professors`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `University`.`Professors` (
  `ProfessorID` INT NULL ,
  `Name` VARCHAR(45) NULL ,
  `DepartmentID` INT NULL ,
  PRIMARY KEY (`ProfessorID`) ,
  INDEX `DepartmentID_idx` (`DepartmentID` ASC) ,
  CONSTRAINT `DepartmentID`
    FOREIGN KEY (`DepartmentID` )
    REFERENCES `University`.`Departments` (`DepartmentID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `University`.`Courses`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `University`.`Courses` (
  `CourseID` INT NULL ,
  `DepartmentID` INT NULL ,
  `CoursesName` VARCHAR(45) NULL ,
  `ProfessorID` INT NULL ,
  PRIMARY KEY (`CourseID`) ,
  INDEX `DepartmentID_idx` (`DepartmentID` ASC) ,
  INDEX `ProfessorID_idx` (`ProfessorID` ASC) ,
  CONSTRAINT `DepartmentID`
    FOREIGN KEY (`DepartmentID` )
    REFERENCES `University`.`Departments` (`DepartmentID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `ProfessorID`
    FOREIGN KEY (`ProfessorID` )
    REFERENCES `University`.`Professors` (`ProfessorID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `University`.`Students_Courses`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `University`.`Students_Courses` (
  `StudentID` INT NULL ,
  `CourseID` INT NULL ,
  PRIMARY KEY (`StudentID`, `CourseID`) ,
  INDEX `StudentID_idx` (`StudentID` ASC) ,
  INDEX `CourseID_idx` (`CourseID` ASC) ,
  CONSTRAINT `StudentID`
    FOREIGN KEY (`StudentID` )
    REFERENCES `University`.`Students` (`StudentID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `CourseID`
    FOREIGN KEY (`CourseID` )
    REFERENCES `University`.`Courses` (`CourseID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `University`.`Titles`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `University`.`Titles` (
  `TitleID` INT NULL ,
  `ProfessorID` INT NULL ,
  `Name` VARCHAR(45) NULL ,
  PRIMARY KEY (`TitleID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `University`.`Professors_Titles`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `University`.`Professors_Titles` (
  `ProfessorID` INT NOT NULL ,
  `TitleID` INT NOT NULL ,
  PRIMARY KEY (`ProfessorID`, `TitleID`) ,
  INDEX `ProfessorID_idx` (`ProfessorID` ASC) ,
  INDEX `TitleID_idx` (`TitleID` ASC) ,
  CONSTRAINT `ProfessorID`
    FOREIGN KEY (`ProfessorID` )
    REFERENCES `University`.`Professors` (`ProfessorID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `TitleID`
    FOREIGN KEY (`TitleID` )
    REFERENCES `University`.`Titles` (`TitleID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `University` ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
