describe("DownloadService", ->
  it("should be a thing that exists", ->
    expect(DownloadService).toBeDefined()
  )

  it("given an area, stores the area as an instance variable", ->
    area = {}
    offlineLayer = {}
    service = new DownloadService(area, offlineLayer)

    expect(service.area).toBe(area)
  )

  beforeEach( ->
    window.cordova = {
      file: {
        documentsDirectory: "/User/Lieferschein/Documents/"
      }
    }
  )

  describe(".downloadHabitatTiles()", ->
    beforeEach( ->
      @area = new BlueCarbon.Models.Area(id: 12)
      @service = new DownloadService(@area, {})
      sinon.stub(@service, 'updateArea')

      @layer = {
        habitat: "seagrass"
        url: "http://seagrass.com/api/seagrass.json"
      }

      window.FileTransfer = ->
    )

    it("given a habitat layer object, downloads the mbtiles file for the
     habitat and saves to the file system", (done) ->
      FileTransfer:: = { download: (url, name, callback) ->
        callback()
      }

      spy = sinon.spy(FileTransfer::, "download")

      mbtilesPath = "/User/Lieferschein/Documents/12-seagrass.mbtiles"
      @service.downloadHabitatTiles(@layer, =>
        expect(
          spy.calledWith(@layer.url, mbtilesPath)
        ).toBe(true)

        done()
      )
    )

    it("passes an error with the callback if the transfer is
     unsuccessful", (done) ->
      FileTransfer:: = { download: (url, name, cb, errorcb) ->
        errorcb("ERRORORORORRORORO")
      }

      @service.downloadHabitatTiles(@layer, (error) ->
        expect(error).toBe("ERRORORORORRORORO")
        done()
      )
    )
  )

  describe('.updateArea', ->
    it("sets the mbtiles attribute on the Area", ->
      layers = [{
        habitat: 'mangroves'
      },{
        habitat: 'seamarshsaltoves'
      }]

      newLayer = {
        habitat: 'mangroves'
        tatibah: 'sevorgnam'
      }

      area = new BlueCarbon.Models.Area(id: 12, mbtiles: layers)
      saveStub = sinon.stub(area, 'localSave')

      sinon.stub(Date::, 'getTime', -> 1234567)

      service = new DownloadService(area, {})
      service.updateArea(newLayer)

      expectedLayers = [{
        habitat: 'mangroves'
        tatibah: 'sevorgnam'
        downloadedAt: 1234567
      },{
        habitat: 'seamarshsaltoves'
      }]

      expect(area.get('mbtiles')).toEqual(expectedLayers)
      expect(saveStub.called).toBe(true)
    )
  )

  describe(".downloadHabitats", ->
    beforeEach( ->
      @layers = [{
        habitat: "seagrass"
        url: "http://seagrass.com/api/seagrass.json"
      }, {
        habitat: "mangroves"
        url: "https://mangroves.io/api/mangroves.json"
      }]

      @area = new BlueCarbon.Models.Area(id: 12, mbtiles: @layers)
      @service = new DownloadService(@area, {})
      sinon.stub(@service, 'updateArea')

      window.FileTransfer = ->
      FileTransfer:: = { download: (url, name, callback) -> callback() }
    )

    it("downloads the habitat layers", (done, fail) ->
      @service.downloadHabitats().then(done).catch(fail)
    )
  )

  describe('.downloadBaseLayer', ->
    beforeEach( ->
      @offlineLayer = {saveTiles: (->), on: (->)}
      @area = new BlueCarbon.Models.Area(id: 12)
      @service = new DownloadService(@area, @offlineLayer)
    )

    it('resolves the promise if the tile saving is successful', (done, fail) ->
      stub = sinon.stub(
        @offlineLayer, 'saveTiles',
        (zoom, startcb, cb, errorcb) -> cb()
      )

      @service.downloadBaseLayer().then( ->
        expect(stub.called).toBe(true)
        done()
      ).catch((err) -> console.log err)
    )

    it('rejects the promise if the tile saving is unsuccessful', (done, fail) ->
      stub = sinon.stub(
        @offlineLayer, 'saveTiles',
        (zoom, startcb, cb, errorcb) -> errorcb(new Error('ERRORORORO'))
      )

      @service.downloadBaseLayer().then(fail).catch(->
        expect(stub.called).toBe(true)
        done()
      )
    )
  )

  describe('.downloadArea', ->
    beforeEach( ->
      @offlineLayer = {saveTiles: (->), calculateNbTiles: (-> []), on: (->)}
      @area = new BlueCarbon.Models.Area(id: 12, mbtiles: [])
      @service = new DownloadService(@area, @offlineLayer)
    )

    it('calculates number of total jobs,
     downloads habitats and base layer', (done, fail) ->
      calculateTotalJobsStub = sinon.stub(@service, 'calculateTotalJobs')
      downloadHabitatsStub = sinon.stub(@service, 'downloadHabitats').
        returns(Promise.resolve())
      downloadBaseLayerStub = sinon.stub(@service, 'downloadBaseLayer').
        returns(Promise.resolve())

      @service.downloadArea({}).then(->
        expect(calculateTotalJobsStub.called).toBe(true)
        expect(downloadHabitatsStub.called).toBe(true)
        expect(downloadBaseLayerStub.called).toBe(true)
        done()
      ).catch(fail)
    )
  )

  describe('.calculateTotalJobs', ->
    it('calculates how many tiles and habitats have to be downloaded', ->
      offlineLayer = {calculateNbTiles: (-> 100)}
      area = new BlueCarbon.Models.Area(id: 12, mbtiles: ['habitat1', 'habitat2'])
      service = new DownloadService(area, offlineLayer)

      expect(service.calculateTotalJobs()).toBe(102)
    )
  )

  describe('.notifyCompletedJob', ->
    it('augments the number of completed jobs and the completion percentage', ->
      service = new DownloadService({}, {})
      service.totalJobs = 2

      expect(service.completedJobs).toBe(0)
      expect(service.completedPercentage).toBe(0)

      service.notifyCompletedJob()

      expect(service.completedJobs).toBe(1)
      expect(service.completedPercentage).toBe(50)
    )

    it('calls the notifying callback, if set', ->
      spy = sinon.spy()

      service = new DownloadService({}, {})
      service.onPercentageChange = spy

      service.notifyCompletedJob()
      expect(spy.called).toBe(true)
    )
  )
)
